CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  reply_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes(
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname,lname)
VALUES
  ('bob', 'miller'),
  ('tim', 'jim');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('title','what?',(SELECT id FROM users WHERE fname = 'bob'));

INSERT INTO
  replies (question_id, user_id, body, reply_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'title'), (SELECT id FROM users WHERE fname = 'tim'),'reply',null);

INSERT INTO
  replies (question_id, user_id, body, reply_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'title'), (SELECT id FROM users WHERE fname = 'bob'),'reply2',(SELECT id FROM replies WHERE body = 'reply'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'bob'),(SELECT id FROM questions WHERE title = 'title'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'bob'),(SELECT id FROM questions WHERE title = 'title'));
