require_relative 'questions_database'

class QuestionFollow
  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON (users.id = questions_follows.user_id)
      WHERE
        question_follows.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON (questions.id = questions_follows.question_id)
      WHERE
        question_follows.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n=1)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *, COUNT(*)
      FROM
        questions
      JOIN
        question_follows ON (questions.id = questions_follows.question_id)
      GROUP BY
        question.id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL
    questions.map { |question| Question.new(question) }
  end
end
