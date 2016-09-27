require_relative 'questions_database'

class Question < ModelBase
  attr_accessor :title, :body
  attr_reader :user_id, :id

  # def self.find_by_id(id)
  #   super(id)
    # questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    #   SELECT
    #     *
    #   FROM
    #     questions
    #   WHERE
    #     user_id = ?
    # SQL
    #
    # questions.map { |question| Question.new(question)  }
  # end

  def self.find_by_author(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL,user_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL

    questions.map{|question| Question.new(question)}
  end


  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(user.first)
  end

  def replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    replies.map { |reply| Reply.new(reply)  }
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n=1)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n=1)
    QuestionLike.most_liked(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end


end
