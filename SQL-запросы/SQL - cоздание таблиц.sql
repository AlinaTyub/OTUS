CREATE TABLE users
(
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(20) UNIQUE,
    email VARCHAR(80) UNIQUE NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE posts
(
    id INT NOT NULL AUTO_INCREMENT,
    body TEXT,
    user_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

INSERT INTO users (username, email)
VALUES ('Ivan Demkin', 'ivandem47@yandex.ru'),
	  ('Gleb Trushin', 'Glebtr345@mail.ru');

INSERT INTO posts (body, user_id)
VALUES ('Bootstrap хорошо работает, когда мы уверены, что наша выборка репрезентативно отражает ГС. При маленькой выборке, мы не можем быть уверены в результате.', 1),
	  ('Конверсия - отношение количества пользователей, совершивших целевое действие, к общему количеству пользователей', 2),
       ('SQL - это язык структурированных запросов для работы с реляционными базами данных', 1);