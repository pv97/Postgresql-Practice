require 'sqlite3'
require 'singleton'
require 'active_support/inflector'
require_relative 'questions'
require_relative 'users'
require_relative 'replies'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class ModelBase
  def self.find_by_id(id)
    matches = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{self.to_s.tableize}
      WHERE
        id = :id
    SQL

    matches.map { |match| self.new(match)  }
  end

  def save
    if hash_variables['id'].nil?
      create
    else
      update
    end
  end

  def create
    vars = hash_variables
    var_keys = stringize_keys(vars)
    var_vals = stringize_vals(vars)
    QuestionsDatabase.instance.execute(<<-SQL)
      INSERT INTO #{self.class.to_s.tableize} #{var_keys}
      VALUES #{var_vals};
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    vars = hash_variables
    id = vars['id']
    vars.delete('id')
    var_string = stringize(vars)
    QuestionsDatabase.instance.execute(<<-SQL)
      UPDATE
        #{self.class.to_s.tableize}
      SET
        #{var_string}
      WHERE
        id = #{id}
    SQL
  end

  def self.where(hash)
    constraints = stringize(hash)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.to_s.tableize}
      WHERE
        #{constraints}
    SQL
    results.map { |result| self.new(result) }
  end

  def self.stringize(hash)
    array = []
    hash.each do |key,val|
      array << "#{key} = '#{val}'"
    end
    array.join(", ")
  end

  def self.stringize_keys(hash)
    array = []
    hash.each do |key,val|
      array << "#{key}"
    end
    array.join(", ")
  end

  def self.stringize_vals(hash)
    array = []
    hash.each do |key,val|
      array << "'#{val}'"
    end
    array.join(", ")
  end

  def hash_variables
    vars = self.instance_variables
    hash = {}
    vars.each do |var|
      hash[var.to_s[1..-1]] = self.instance_variable_get(var)
    end
    hash
  end
end
