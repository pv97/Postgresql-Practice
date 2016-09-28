class QuestionLike
  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON (questions.id = question_likes.question_id)
      WHERE
        question_likes.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON (users.id = question_likes.user_id)
      WHERE
        question_likes.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id)
      FROM
        question_likes
      WHERE
        question_likes.question_id = ?
    SQL
    count.first.values.first
  end


  def self.most_liked_questions(n=1)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *, COUNT(*)
      FROM
        questions
      JOIN
        question_likes ON (questions.id = questions_likes.question_id)
      GROUP BY
        question.id
      ORDER BY
        COUNT(*)
      LIMIT ?
    SQL
    questions.map { |question| Question.new(question) }
  end
end
