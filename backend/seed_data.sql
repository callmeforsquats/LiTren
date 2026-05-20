TRUNCATE TABLE
    users,
    authors,
    pubs,
    topics,
    cats,
    bindings,
    towns,
    streets,
    books,
    carts,
    cart_items,
    orders,
    order_items,
    reviews,
    book_authors,
    book_topics,
    cat_topics
RESTART IDENTITY
CASCADE;

-- ========================================================
-- ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ
-- ========================================================
-- ИЗДАТЕЛЬСТВА (10 штук)
INSERT INTO pubs(name, info, picture_url)
    VALUES ('Эксмо', 'Крупнейшее российское издательство, основано в 1991 году', '/pubs/exmo.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('АСТ', 'Одно из ведущих издательств художественной литературы', '/pubs/ast.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('МИФ', 'Издательство Манн, Иванов и Фербер – деловая и развивающая литература', '/pubs/mif.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Питер', 'Издательство профессиональной и учебной литературы', '/pubs/piter.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Азбука-Аттикус', 'Издательство классической и современной зарубежной прозы', '/pubs/azbuka.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Альпина Паблишер', 'Деловая литература, нон-фикшн, научпоп', '/pubs/alpina.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Росмэн', 'Детская и образовательная литература', '/pubs/rosman.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Новое литературное обозрение', 'Гуманитарная и научная литература', '/pubs/nlo.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Лабиринт Пресс', 'Познавательная литература для детей и взрослых', '/pubs/labirint.jpg');

INSERT INTO pubs(name, info, picture_url)
    VALUES ('Вече', 'Историческая и патриотическая литература', '/pubs/veche.jpg');

SELECT
    COUNT(*)
FROM
    pubs;

-- КАТЕГОРИИ (4 крупных с 4-5 подкатегориями)
-- Художественная литература (id 1)
INSERT INTO cats(name, parent_id)
    VALUES ('Художественная литература', NULL);

INSERT INTO cats(name, parent_id)
    VALUES ('Русская классика', 1);

INSERT INTO cats(name, parent_id)
    VALUES ('Зарубежная классика', 1);

INSERT INTO cats(name, parent_id)
    VALUES ('Современная проза', 1);

INSERT INTO cats(name, parent_id)
    VALUES ('Фантастика и фэнтези', 1);

INSERT INTO cats(name, parent_id)
    VALUES ('Детективы и триллеры', 1);

-- Деловая литература (id 7)
INSERT INTO cats(name, parent_id)
    VALUES ('Деловая литература', NULL);

INSERT INTO cats(name, parent_id)
    VALUES ('Бизнес и менеджмент', 7);

INSERT INTO cats(name, parent_id)
    VALUES ('Маркетинг и реклама', 7);

INSERT INTO cats(name, parent_id)
    VALUES ('Финансы и инвестиции', 7);

INSERT INTO cats(name, parent_id)
    VALUES ('Карьера и саморазвитие', 7);

-- Научно-популярная литература (id 12)
INSERT INTO cats(name, parent_id)
    VALUES ('Научно-популярная литература', NULL);

INSERT INTO cats(name, parent_id)
    VALUES ('Физика и математика', 12);

INSERT INTO cats(name, parent_id)
    VALUES ('Биология и медицина', 12);

INSERT INTO cats(name, parent_id)
    VALUES ('Космос и астрономия', 12);

INSERT INTO cats(name, parent_id)
    VALUES ('История и археология', 12);

INSERT INTO cats(name, parent_id)
    VALUES ('Психология', 12);

-- Детская литература (id 18)
INSERT INTO cats(name, parent_id)
    VALUES ('Детская литература', NULL);

INSERT INTO cats(name, parent_id)
    VALUES ('Сказки', 18);

INSERT INTO cats(name, parent_id)
    VALUES ('Приключения', 18);

INSERT INTO cats(name, parent_id)
    VALUES ('Познавательная литература', 18);

INSERT INTO cats(name, parent_id)
    VALUES ('Комиксы', 18);

-- ========================================================
-- ПОСТРОЕНИЕ ПУТЕЙ КАТЕГОРИЙ (триггер сработает автоматически)
-- Пути пересчитаются после вставки всех категорий
-- ========================================================
-- ПЕРЕПЛЁТЫ
INSERT INTO bindings(name)
    VALUES ('Твёрдый переплёт');

INSERT INTO bindings(name)
    VALUES ('Мягкая обложка');

INSERT INTO bindings(name)
    VALUES ('Суперобложка');

INSERT INTO bindings(name)
    VALUES ('Интегральная обложка');

-- ТЕМЫ (50 штук - общие темы для книг)
INSERT INTO topics(name)
    VALUES ('искусственный интеллект');

INSERT INTO topics(name)
    VALUES ('машинное обучение');

INSERT INTO topics(name)
    VALUES ('python');

INSERT INTO topics(name)
    VALUES ('sql');

INSERT INTO topics(name)
    VALUES ('java');

INSERT INTO topics(name)
    VALUES ('веб-разработка');

INSERT INTO topics(name)
    VALUES ('фронтенд');

INSERT INTO topics(name)
    VALUES ('кибербезопасность');

INSERT INTO topics(name)
    VALUES ('космос');

INSERT INTO topics(name)
    VALUES ('астрофизика');

INSERT INTO topics(name)
    VALUES ('черные дыры');

INSERT INTO topics(name)
    VALUES ('планеты');

INSERT INTO topics(name)
    VALUES ('биология');

INSERT INTO topics(name)
    VALUES ('генетика');

INSERT INTO topics(name)
    VALUES ('нейробиология');

INSERT INTO topics(name)
    VALUES ('эволюция');

INSERT INTO topics(name)
    VALUES ('история');

INSERT INTO topics(name)
    VALUES ('вторая мировая война');

INSERT INTO topics(name)
    VALUES ('древний рим');

INSERT INTO topics(name)
    VALUES ('средневековье');

INSERT INTO topics(name)
    VALUES ('психология');

INSERT INTO topics(name)
    VALUES ('саморазвитие');

INSERT INTO topics(name)
    VALUES ('мотивация');

INSERT INTO topics(name)
    VALUES ('продуктивность');

INSERT INTO topics(name)
    VALUES ('маркетинг');

INSERT INTO topics(name)
    VALUES ('реклама');

INSERT INTO topics(name)
    VALUES ('инвестиции');

INSERT INTO topics(name)
    VALUES ('финансы');

INSERT INTO topics(name)
    VALUES ('бизнес');

INSERT INTO topics(name)
    VALUES ('стартапы');

INSERT INTO topics(name)
    VALUES ('менеджмент');

INSERT INTO topics(name)
    VALUES ('лидерство');

INSERT INTO topics(name)
    VALUES ('фэнтези');

INSERT INTO topics(name)
    VALUES ('магия');

INSERT INTO topics(name)
    VALUES ('драконы');

INSERT INTO topics(name)
    VALUES ('космическая опера');

INSERT INTO topics(name)
    VALUES ('киберпанк');

INSERT INTO topics(name)
    VALUES ('детектив');

INSERT INTO topics(name)
    VALUES ('триллер');

INSERT INTO topics(name)
    VALUES ('любовный роман');

INSERT INTO topics(name)
    VALUES ('приключения');

INSERT INTO topics(name)
    VALUES ('путешествия');

INSERT INTO topics(name)
    VALUES ('сказки');

INSERT INTO topics(name)
    VALUES ('мифология');

INSERT INTO topics(name)
    VALUES ('философия');

INSERT INTO topics(name)
    VALUES ('поэзия');

INSERT INTO topics(name)
    VALUES ('драма');

INSERT INTO topics(name)
    VALUES ('сатира');

INSERT INTO topics(name)
    VALUES ('ужасы');

INSERT INTO topics(name)
    VALUES ('постапокалипсис');

SELECT
    count(*)
FROM
    topics;

-- ========================================================
-- АВТОРЫ (50 штук)
-- ========================================================
INSERT INTO authors(name, bio, picture_url)
    VALUES ('Лев Толстой', 'Великий русский писатель и мыслитель, автор романов "Война и мир" и "Анна Каренина"', '/authors/tolstoy.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Фёдор Достоевский', 'Классик русской литературы, мастер психологической прозы', '/authors/dostoevsky.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Антон Чехов', 'Великий русский писатель и драматург', '/authors/chekhov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джордж Оруэлл', 'Британский писатель и публицист, автор "1984" и "Скотный двор"', '/authors/orwell.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Эрнест Хемингуэй', 'Американский писатель, лауреат Нобелевской премии', '/authors/hemingway.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Франц Кафка', 'Австрийский писатель еврейского происхождения', '/authors/kafka.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Габриэль Гарсиа Маркес', 'Колумбийский писатель, лауреат Нобелевской премии', '/authors/marquez.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джоан Роулинг', 'Британская писательница, автор серии романов о Гарри Поттере', '/authors/rowling.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джон Р. Р. Толкин', 'Английский писатель, автор "Властелина колец"', '/authors/tolkien.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джордж Мартин', 'Американский писатель, автор "Песни льда и огня"', '/authors/martin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Стивен Кинг', 'Американский писатель, мастер ужасов и триллеров', '/authors/king.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Агата Кристи', 'Английская писательница, королева детектива', '/authors/christie.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Артур Конан Дойл', 'Английский писатель, создатель Шерлока Холмса', '/authors/doyle.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Рэй Брэдбери', 'Американский писатель-фантаст', '/authors/bradbury.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Айзек Азимов', 'Американский писатель-фантаст, биохимик', '/authors/asimov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Стивен Хокинг', 'Британский физик-теоретик и популяризатор науки', '/authors/hawking.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Ричард Докинз', 'Британский этолог, эволюционный биолог', '/authors/dawkins.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Юваль Ной Харари', 'Израильский историк, автор "Sapiens"', '/authors/harari.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Митио Каку', 'Американский физик японского происхождения', '/authors/kaku.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Карл Саган', 'Американский астроном и популяризатор науки', '/authors/sagan.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Нассим Талеб', 'Американский эссеист и трейдер ливанского происхождения', '/authors/taleb.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Роберт Кийосаки', 'Американский предприниматель и писатель', '/authors/kiyosaki.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Дейл Карнеги', 'Американский педагог и писатель', '/authors/carnegie.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Дэниел Канеман', 'Израильско-американский психолог, лауреат Нобелевской премии', '/authors/kahneman.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Малкольм Гладуэлл', 'Канадский журналист и писатель', '/authors/gladwell.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Саймон Синек', 'Американский писатель и мотивационный спикер', '/authors/sinek.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Сет Годин', 'Американский маркетолог и предприниматель', '/authors/godin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Фил Найт', 'Американский бизнесмен, сооснователь Nike', '/authors/knight.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Эрик Рис', 'Американский предприниматель, автор концепции "Бережливый стартап"', '/authors/ries.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джейсон Фрайд', 'Американский предприниматель, сооснователь Basecamp', '/authors/fried.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Мария Конникова', 'Американская писательница и журналистка русского происхождения', '/authors/konnikova.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Кэл Ньюпорт', 'Американский писатель и профессор информатики', '/authors/newport.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джеймс Клир', 'Американский писатель, автор "Атомных привычек"', '/authors/clear.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Чарльз Дюхигг', 'Американский журналист и писатель', '/authors/duhigg.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Нил Гейман', 'Английский писатель-фантаст', '/authors/gaiman.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Терри Пратчетт', 'Английский писатель, автор Плоского мира', '/authors/pratchett.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Урсула Ле Гуин', 'Американская писательница-фантаст', '/authors/leguin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Филип Дик', 'Американский писатель-фантаст', '/authors/dick.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Уильям Гибсон', 'Американский писатель-фантаст, основоположник киберпанка', '/authors/gibson.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Борис Акунин', 'Российский писатель, автор книг об Эрасте Фандорине', '/authors/akunin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Виктор Пелевин', 'Российский писатель-постмодернист', '/authors/pelevin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Татьяна Устинова', 'Российская писательница детективного жанра', '/authors/ustinova.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Александра Маринина', 'Российская писательница, автор детективов', '/authors/marinina.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Михаил Булгаков', 'Русский писатель и драматург', '/authors/bulgakov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Александр Солженицын', 'Русский писатель, лауреат Нобелевской премии', '/authors/solzhenitsyn.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Иван Тургенев', 'Русский писатель-реалист', '/authors/turgenev.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Николай Гоголь', 'Русский прозаик и драматург', '/authors/gogol.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Александр Пушкин', 'Великий русский поэт и писатель', '/authors/pushkin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Михаил Лермонтов', 'Русский поэт и писатель', '/authors/lermontov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Антуан де Сент-Экзюпери', 'Французский писатель и лётчик', '/authors/exupery.jpg');

SELECT
    count(*)
FROM
    authors;

-- ========================================================
-- КНИГИ (150 книг с аннотациями)
-- ========================================================
-- Категория: Русская классика (cat_id = 2)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Война и мир', 'Вершина творчества Льва Толстого — грандиозный роман-эпопея "Война и мир", описывающий события наполеоновских войн и жизнь русского общества начала XIX века. В центре повествования — судьбы аристократических семей Болконских, Ростовых и Безуховых на фоне исторических катастроф. Толстой мастерски переплетает личные драмы героев с масштабными батальными сценами, создавая глубокое философское размышление о свободе воли, исторической необходимости и истинном героизме. Роман неоднократно экранизировался и остается одним из самых читаемых произведений мировой литературы.', 599.99, '978-5-04-098643-1', 1408, 1, 2, 1, TRUE, FALSE, 18500, 12500, 4.85, 4580, '/books/war_and_peace.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Анна Каренина', 'Трагическая история любви замужней дамы Анны Карениной к блестящему офицеру Алексею Вронскому на фоне петербургского высшего света. Параллельно развивается линия счастливой семьи Константина Левина и Кити Щербацкой, размышления о смысле жизни, труде и вере. Толстой создает многоплановое повествование о браке, измене, социальных условностях и поиске счастья.', 499.99, '978-5-699-69437-2', 864, 1, 2, 1, TRUE, FALSE, 12400, 8900, 4.78, 3250, '/books/anna_karenina.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Преступление и наказание', 'Роман о студенте Родионе Раскольникове, который убивает старуху-процентщицу, проверяя свою теорию о "право имеющих" и "тварях дрожащих". После преступления героя мучает совесть, и только любовь Сони Мармеладовой помогает ему найти путь к искуплению. Достоевский исследует природу добра и зла, границы человеческой воли и силу раскаяния.', 450.00, '978-5-17-118934-5', 672, 1, 2, 2, TRUE, FALSE, 15600, 11200, 4.92, 5120, '/books/crime_punishment.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Братья Карамазовы', 'Последний роман Достоевского, вершина его творчества. История семьи Карамазовых — отца Федора Павловича и его сыновей: чувственного Дмитрия, рационального Ивана и кроткого Алексея. Философская драма о вере, сомнении, свободе воли и убийстве, включающая знаменитую "Легенду о Великом инквизиторе".', 599.00, '978-5-04-108331-5', 800, 1, 2, 1, TRUE, TRUE, 9800, 6700, 4.88, 4100, '/books/brothers_karamazov.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Вишнёвый сад', 'Последняя пьеса Антона Чехова, лирическая комедия о разорявшейся дворянской семье Гаевых-Раневских, вынужденной продавать свое родовое имение с вишневым садом. В пьесе переплетаются темы уходящей дворянской культуры, прихода нового буржуазного века и ностальгии по прошлому.', 299.99, '978-5-389-15234-6', 160, 2, 2, 5, FALSE, FALSE, 5400, 3200, 4.65, 1890, '/books/cherry_orchard.jpg');

-- Категория: Зарубежная классика (cat_id = 3)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('1984', 'Роман-антиутопия Джорджа Оруэлла о тоталитарном обществе, где Большой Брат следит за каждым шагом граждан. Главный герой Уинстон Смит работает в Министерстве правды, переписывая историю, и решает бунтовать против системы, за что его ждут пытки и предательство. Книга стала символом борьбы со слежкой и манипуляцией сознанием.', 399.00, '978-5-04-102422-6', 384, 1, 3, 2, TRUE, FALSE, 21000, 15600, 4.95, 8900, '/books/1984.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Скотный двор', 'Сатирическая повесть-притча о животных, которые изгоняют хозяина-человека и строят общество всеобщего равенства. Лозунг "Все животные равны" быстро трансформируется в "Все животные равны, но некоторые равнее", когда свиньи захватывают власть. Оруэлл мастерски изображает механизмы перерождения революции в диктатуру.', 299.00, '978-5-17-119330-4', 160, 2, 3, 2, TRUE, FALSE, 12300, 8900, 4.87, 4560, '/books/animal_farm.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Старик и море', 'Философская повесть Эрнеста Хемингуэя о кубинском рыбаке Сантьяго, который после 84 дней неудач выходит в море и ловит гигантского марлина. Повесть о мужестве, достоинстве и стойкости человека перед лицом природы и судьбы, принесшая автору Пулитцеровскую премию и Нобелевскую премию.', 349.00, '978-5-04-093984-0', 128, 2, 3, 2, TRUE, FALSE, 9800, 6700, 4.80, 3410, '/books/old_man_sea.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Процесс', 'Роман Франца Кафки о банковском служащем Йозефе К., который однажды утром обнаруживает, что арестован по неизвестному обвинению. Он погружается в абсурдный, бюрократический и недоступный для понимания мир судебной системы, где никогда не узнает ни своего обвинения, ни способа его опровергнуть.', 399.99, '978-5-389-14567-6', 320, 1, 3, 5, FALSE, FALSE, 6500, 4100, 4.73, 2150, '/books/trial.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сто лет одиночества', 'Магический реализм Габриэля Гарсиа Маркеса в истории шести поколений семьи Буэндиа из вымышленного города Макондо. Роман охватывает историю Латинской Америки, переплетая реальность с мифами, пророчествами и чудесами. Классик мировой литературы XX века.', 550.00, '978-5-17-118885-0', 544, 1, 3, 2, TRUE, FALSE, 11200, 7800, 4.91, 4670, '/books/hundred_years_solitude.jpg');

-- Категория: Современная проза (cat_id = 4)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Generation П', 'Культовый роман Виктора Пелевина о Вавилене Татарском, который после распада СССР начинает работать в рекламе. Роман исследует постсоветскую действительность, массовую культуру, психологию потребителя и мистические аспекты современного общества.', 450.00, '978-5-04-111664-8', 416, 1, 4, 2, TRUE, FALSE, 8700, 5600, 4.75, 2890, '/books/generation_p.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Норвежский лес', 'Трогательная история любви и потери Харуки Мураками о студенте Тору Ватанабэ, который вспоминает свою юность в 1960-х годах. Роман о любви к двум разным женщинам — прекрасной и загадочной Наоко и жизнерадостной Мидори, о самоубийстве, психических расстройствах и взрослении.', 499.00, '978-5-86471-867-4', 384, 1, 4, 5, TRUE, FALSE, 9300, 6400, 4.82, 3540, '/books/norwegian_wood.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('451 градус по Фаренгейту', 'Роман-антиутопия Рэя Брэдбери о мире, где пожарные не тушат пожары, а сжигают книги. Главный герой Гай Монтэг начинает сомневаться в своем предназначении после встречи с юной соседкой Клариссой, которая заставляет его задуматься о том, что теряет человечество, уничтожая литературу.', 399.00, '978-5-04-091287-4', 320, 1, 4, 2, TRUE, FALSE, 14500, 10200, 4.89, 5230, '/books/fahrenheit_451.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Шантарам', 'Эпический роман Грегори Дэвида Робертса о австралийском беглеце Линдсее, который находит убежище в трущобах Мумбаи. История о преступности, любви, дружбе, духовном поиске и путешествии от отчаяния к искуплению. Основано на реальной жизни автора.', 650.00, '978-5-17-116898-2', 864, 1, 4, 2, TRUE, TRUE, 17800, 12400, 4.93, 6780, '/books/shantaram.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Маленький принц', 'Философская сказка Антуана де Сент-Экзюпери о дружбе маленького принца с разных планет с летчиком, потерпевшим крушение в пустыне Сахара. Притча о любви, одиночестве, ответственности и главных истинах жизни.', 299.00, '978-5-04-098458-1', 128, 1, 4, 2, TRUE, FALSE, 16700, 12300, 4.97, 8450, '/books/little_prince.jpg');

-- Категория: Фантастика и фэнтези (cat_id = 5)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Гарри Поттер и философский камень', 'Первый роман Джоан Роулинг о мальчике, который узнает в свой 11-й день рождения, что он волшебник. Гарри поступает в школу чародейства и волшебства Хогвартс, где находит друзей Рона и Гермиону и сталкивается с темным волшебником, убившим его родителей.', 399.00, '978-5-04-099539-6', 432, 1, 5, 1, TRUE, FALSE, 23400, 18700, 4.98, 12450, '/books/harry_potter_1.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Властелин колец: Братство кольца', 'Первая часть эпопеи Джона Р. Р. Толкина о Средиземье. Молодой хоббит Фродо Бэггинс получает в наследство Кольцо Всевластья, которое нужно уничтожить в огне Роковой горы. К нему присоединяются хранители-спутники: Арагорн, Гэндальф, Леголас, Гимли и другие.', 599.00, '978-5-17-119378-6', 576, 1, 5, 2, TRUE, FALSE, 19800, 14500, 4.96, 9870, '/books/lotr_fellowship.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Игра престолов', 'Первый роман цикла "Песнь льда и огня" Джорджа Мартина. На вымышленном континенте Вестерос благородные дома борются за Железный трон. Интриги, предательства, битвы и возвращение магии в мир, где зима может длиться десятилетиями.', 650.00, '978-5-17-115890-7', 864, 1, 5, 2, TRUE, FALSE, 18700, 13200, 4.94, 8760, '/books/game_of_thrones.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Американские боги', 'Роман Нила Геймана о Тени Муне, который выходит из тюрьмы и нанимается телохранителем к загадочному господину Среда. Вместе они путешествуют по Америке, собирая старых богов, привезенных иммигрантами, для битвы с новыми богами интернета, медиа и технологий.', 550.00, '978-5-17-117124-1', 640, 1, 5, 2, FALSE, FALSE, 8900, 5600, 4.85, 3420, '/books/american_gods.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Нейромант', 'Классический роман Уильяма Гибсона, основоположник киберпанка. Бывший хакер Кейс получает шанс на искупление и работу от загадочного нанимателя. Ему предстоит взломать искусственный интеллект, который обрел самостоятельность.', 499.00, '978-5-17-115691-0', 384, 1, 5, 2, FALSE, FALSE, 6700, 4300, 4.79, 2890, '/books/neuromancer.jpg');

-- Категория: Детективы и триллеры (cat_id = 6)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сияние', 'Классический роман ужасов Стивена Кинга о писателе Джеке Торрансе, который устраивается смотрителем в отрезанный от мира отель "Оверлук" на зиму. Вместе с женой и сыном-телепатом он сталкивается со сверхъестественными силами отеля, которые сводят его с ума.', 450.00, '978-5-17-119499-8', 576, 1, 6, 2, TRUE, FALSE, 15400, 11200, 4.90, 5670, '/books/shining.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Десять негритят', 'Гениальный детектив Агаты Кристи. Десять незнакомцев приезжают на остров по приглашению таинственного хозяина. В доме их ждет запись обвинений в преступлениях, которые каждый из них совершил в прошлом. Один за другим гости начинают умирать в соответствии с детской считалкой.', 399.00, '978-5-04-099547-1', 320, 1, 6, 1, TRUE, FALSE, 13200, 9800, 4.92, 5430, '/books/ten_little_indians.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Собака Баскервилей', 'Знаменитая повесть Артура Конан Дойла о Шерлоке Холмсе. Сэр Чарльз Баскервиль найден мертвым, и все указывают на проклятие древнего рода — гигантскую собаку-призрака. Холмс отправляет Ватсона в мрачные болота Девоншира.', 349.00, '978-5-04-099102-2', 256, 1, 6, 1, FALSE, FALSE, 9800, 6700, 4.88, 4120, '/books/hound_baskervilles.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Убийство в "Восточном экспрессе"', 'Эркюль Пуаро расследует убийство американского миллионера в поезде "Восточный экспресс", застрявшем в снежных заносах в Югославии. Все пассажиры имеют алиби, но у каждого есть мотив, связанный с загадочным преступлением прошлого.', 399.00, '978-5-04-105632-6', 352, 1, 6, 1, TRUE, FALSE, 11200, 7800, 4.91, 4560, '/books/murder_orient_express.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Турецкий гамбит', 'Роман Бориса Акунина об Эрасте Фандорине во время русско-турецкой войны 1877-1878 годов. Загадочный турецкий шпион по кличке "Анвар-эфенди" передает секретные сведения, и молодой дипломат Фандорин пытается его вычислить.', 450.00, '978-5-04-102319-9', 352, 1, 6, 1, TRUE, FALSE, 7600, 4900, 4.83, 3210, '/books/turkish_gambit.jpg');

-- Категория: Бизнес и менеджмент (cat_id = 8)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Богатый папа, бедный папа', 'Бестселлер Роберта Кийосаки о финансовой грамотности. Автор сравнивает подходы к деньгам своего "богатого папы" — отца друга-предпринимателя и "бедного папы" — своего родного отца-учителя. Книга учит мыслить как инвестор, покупать активы, а не пассивы.', 399.00, '978-5-04-091651-3', 352, 1, 8, 2, TRUE, FALSE, 15600, 12300, 4.75, 6540, '/books/rich_dad_poor_dad.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Думай и богатей', 'Классика мотивационной литературы Наполеона Хилла. Автор на основе интервью с 500 успешнейшими людьми Америки, включая Эндрю Карнеги и Генри Форда, вывел 13 принципов достижения успеха, основанных на силе мысли и настойчивости.', 450.00, '978-5-04-092211-8', 384, 1, 8, 2, TRUE, FALSE, 13400, 9800, 4.80, 5210, '/books/think_grow_rich.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('От хорошего к великому', 'Исследование Джима Коллинза о том, почему одни компании совершают прорыв к величию, а другие нет. Автор и его команда проанализировали 1400 компаний и выявили факторы, превращающие хорошую компанию в великую.', 599.00, '978-5-04-097568-8', 416, 1, 8, 3, TRUE, FALSE, 8900, 6100, 4.85, 3870, '/books/good_to_great.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Стартап: 11 мастер-классов', 'Книга основателя TechStars Брэда Фелда для предпринимателей. Сборник практических советов о том, как строить стартап от идеи до выхода: поиск сооснователей, привлечение инвестиций, работа с клиентами, увольнения и кризисы.', 699.00, '978-5-9614-5124-9', 480, 1, 8, 3, FALSE, TRUE, 5600, 3400, 4.72, 2340, '/books/startup_11_masterclasses.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Rework: Бизнес без предрассудков', 'Манифест от основателей 37signals (Basecamp) Джейсона Фрида и Дэвида Хайнемайера Хэнссона. Книга разрушает мифы традиционного бизнеса: не нужен офис, не нужны инвесторы, не нужно расти любой ценой. Призыв делать меньше, быстрее и умнее.', 499.00, '978-5-04-104776-8', 288, 1, 8, 2, TRUE, FALSE, 7800, 5200, 4.88, 4120, '/books/rework.jpg');

-- Категория: Маркетинг и реклама (cat_id = 9)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Маркетинг без бюджета', 'Книга Игоря Манна, гуру российского маркетинга. Автор доказывает, что эффективный маркетинг возможен без больших бюджетов. 50 практических идей для раскрутки бизнеса с минимальными вложениями на основе реальных кейсов.', 499.00, '978-5-04-096548-1', 288, 1, 9, 2, TRUE, FALSE, 8900, 6300, 4.78, 4120, '/books/marketing_no_budget.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Клиенты на всю жизнь', 'Карл Сьюэлл, владелец сети дилерских центров Cadillac, делится формулой обретения клиентов на всю жизнь. Главный принцип: каждое взаимодействие с клиентом — это возможность, которую нельзя упустить. Система 10 законов предельного сервиса.', 550.00, '978-5-04-092369-6', 320, 1, 9, 2, FALSE, FALSE, 4500, 2800, 4.68, 1870, '/books/customers_for_life.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Джедайские техники', 'Книга Максима Дорофеева о продуктивности и маркетинге в IT. Автор, product owner в крупной компании, рассказывает, как не утонуть в делах, правильно расставлять приоритеты и управлять ожиданиями заказчиков и клиентов.', 450.00, '978-5-04-099416-0', 352, 1, 9, 2, FALSE, FALSE, 6700, 4500, 4.82, 2980, '/books/jedi_techniques.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Копирайтинг: как не съесть собаку', 'Учебник Дениса Каплунова для копирайтеров и маркетологов. Автор разбирает 100 правил и 100 примеров хороших и плохих текстов. От заголовков до посадочных страниц — создание текстов, которые продают.', 499.00, '978-5-04-104872-7', 384, 1, 9, 2, TRUE, FALSE, 8900, 6100, 4.79, 3980, '/books/copywriting.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Взламывая маркетинг', 'Фил Барден, нейробиолог и маркетолог, объясняет, как решения о покупке принимаются на бессознательном уровне. Книга о том, как использовать открытия нейронауки в маркетинге и рекламе для увеличения продаж.', 599.00, '978-5-04-098777-3', 320, 1, 9, 2, FALSE, TRUE, 4900, 3100, 4.71, 2340, '/books/hacking_marketing.jpg');

-- Категория: Финансы и инвестиции (cat_id = 10)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Разумный инвестор', 'Библия стоимостного инвестирования Бенджамина Грэма, учителя Уоррена Баффетта. Книга учит защищать капитал от инфляции и рыночных рисков, различать инвестиции и спекуляции, использовать стратегию "мистер Рынок".', 699.00, '978-5-04-099438-2', 640, 1, 10, 2, TRUE, FALSE, 11200, 7800, 4.92, 5670, '/books/intelligent_investor.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Богатый инвестор, быстрый инвестор', 'Роберт Кийосаки продолжает тему финансовой грамотности. Книга о том, как превратить деньги в богатство через инвестиции в недвижимость и бизнес, создавая денежный поток и используя долг для увеличения капитала.', 450.00, '978-5-04-092957-5', 416, 1, 10, 2, FALSE, FALSE, 8900, 5800, 4.73, 3450, '/books/rich_dad_rich_investor.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Случайная прогулка по Уолл-стрит', 'Бертон Малкиел доказывает, что случайный выбор акций превосходит результаты аналитиков. Классическая книга о пассивном инвестировании в индексные фонды, которую стоит прочитать каждому инвестору-новичку.', 650.00, '978-5-04-097233-5', 560, 1, 10, 2, TRUE, FALSE, 7800, 5100, 4.86, 3980, '/books/random_walk_wall_street.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Мани, или азбука денег', 'Бодо Шефер написал финансовую сказку для взрослых и детей о девочке Кире, собаке Мани и двенадцати правилах обращения с деньгами. Простая и вдохновляющая книга о финансовой грамотности с нуля.', 399.00, '978-5-04-092622-2', 224, 1, 10, 2, TRUE, FALSE, 13400, 10200, 4.88, 6540, '/books/money_dog.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Черный лебедь', 'Нассим Талеб о маловероятных событиях, которые переворачивают мир. Философское эссе о том, как мы не умеем предсказывать будущее, почему банки терпят крах и как построить "антихрупкую" систему, извлекающую выгоду из хаоса.', 699.00, '978-5-04-103438-2', 640, 1, 10, 2, TRUE, FALSE, 14500, 10300, 4.94, 7230, '/books/black_swan.jpg');

-- Категория: Карьера и саморазвитие (cat_id = 11)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Атомные привычки', 'Бестселлер Джеймса Клира о том, как маленькие изменения приводят к большим результатам. Система формирования полезных привычек и избавления от вредных на основе психологии и нейробиологии. Книга года по версии Goodreads.', 550.00, '978-5-04-109008-5', 320, 1, 11, 2, TRUE, FALSE, 18900, 14500, 4.96, 9870, '/books/atomic_habits.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Эссенциализм', 'Грег МакКеон о том, как делать меньше, но лучше. Книга о концентрации на главном: отсечении всего лишнего, чтобы направить энергию на действительно важные задачи. Путь к спокойной продуктивности.', 499.00, '978-5-04-097212-0', 288, 1, 11, 2, TRUE, FALSE, 11200, 7800, 4.87, 4560, '/books/essentialism.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Как завоёвывать друзей', 'Классический бестселлер Дейла Карнеги, не теряющий актуальности десятилетиями. 6 способов расположить к себе людей, 12 правил убеждения и техники влияния, не вызывающие обиды. Главная книга об общении.', 399.00, '978-5-04-102121-8', 288, 1, 11, 2, TRUE, FALSE, 17800, 13400, 4.90, 7890, '/books/how_to_win_friends.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Магия утра', 'Хэл Элрод предлагает утренний ритуал "Спасительный час", который меняет жизнь. Тренировки, медитация, визуализация, чтение и ведение дневника до начала рабочего дня. Как стать утренним человеком и достичь целей.', 450.00, '978-5-04-099810-6', 288, 1, 11, 2, TRUE, FALSE, 12300, 8900, 4.76, 5430, '/books/miracle_morning.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сила воли', 'Рой Баумейстер, психолог-исследователь силы воли, объясняет, почему одни люди успешно достигают целей, а другие срываются. Книга о том, как тренировать самоконтроль как мышцу, питать глюкозой и не истощать ресурс.', 549.00, '978-5-04-104478-1', 384, 1, 11, 2, FALSE, FALSE, 7800, 5600, 4.81, 3450, '/books/willpower.jpg');

-- Категория: Физика и математика (cat_id = 13)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Краткая история времени', 'Стивен Хокинг гениально просто объясняет сложнейшие концепции физики: Большой взрыв, черные дыры, теорию струн, стрелу времени и природу Вселенной. Бестселлер, переведенный на десятки языков, без единой формулы.', 499.00, '978-5-17-113256-3', 256, 1, 13, 2, TRUE, FALSE, 16700, 12400, 4.94, 8760, '/books/brief_history_time.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Будущее разума', 'Митио Каку о том, как технологии изменят человеческий мозг. Нейроинтерфейсы, телепатия, видеозапись снов и возможность загружать сознание в компьютер. Научное обоснование самых смелых фантазий футурологов.', 550.00, '978-5-04-103546-4', 416, 1, 13, 2, TRUE, FALSE, 9800, 6700, 4.85, 4120, '/books/future_of_mind.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Квантовая вселенная', 'Брайан Кокс и Джефф Форшоу объясняют квантовую механику без заумных формул. Двойственная природа частиц, квантовая запутанность, кот Шредингера и практические применения — от телефонов до медицинских томографов.', 599.00, '978-5-04-099456-6', 384, 1, 13, 2, FALSE, FALSE, 7800, 5400, 4.88, 3450, '/books/quantum_universe.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Черные дыры и молодые вселенные', 'Стивен Хокинг размышляет о черных дырах, происхождении Вселенной и будущем человечества. Сборник лекций и эссе от гениального физика, где он предсказывает путешествия во времени и исчезновение информации в черных дырах.', 499.00, '978-5-17-093267-9', 224, 1, 13, 2, FALSE, TRUE, 8900, 5600, 4.79, 2670, '/books/black_holes.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Как математика меняет мир', 'Джордан Элленберг показывает, как математическое мышление проникает во все сферы жизни. От политических опросов до биологии рака — математика помогает увидеть неочевидные закономерности и принимать лучшие решения.', 599.00, '978-5-04-103545-7', 480, 1, 13, 2, TRUE, FALSE, 6700, 4300, 4.76, 2980, '/books/math_changes_world.jpg');

-- Категория: Космос и астрономия (cat_id = 15)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Космос: Эволюция Вселенной', 'Карл Саган — великий популяризатор астрономии — приглашает в космическое путешествие от микромира до галактик. Иллюстрированный бестселлер, вдохновивший миллионы людей на изучение звездного неба.', 699.00, '978-5-04-099877-9', 480, 1, 15, 2, TRUE, FALSE, 14500, 10300, 4.93, 6540, '/books/cosmos.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Астрофизика с космической скоростью', 'Нил Деграсс Тайсон, директор планетария Хайдена, с юмором рассказывает о самых важных вещах во Вселенной. Квантовая механика, темная материя, черные дыры и поиски жизни на Марсе.', 550.00, '978-5-04-104403-3', 288, 1, 15, 2, TRUE, FALSE, 11200, 7800, 4.91, 4870, '/books/astrophysics_people_hurry.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Парадоксы космоса', 'Андрей Линде, один из создателей теории вечной инфляции, объясняет, почему Вселенная такая, какая есть. Мультивселенная, квантовая космология и возможность существования множества параллельных миров.', 699.00, '978-5-04-105432-2', 368, 1, 15, 2, FALSE, TRUE, 5600, 3400, 4.74, 2340, '/books/paradoxes_cosmos.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Книга о Луне', 'Марика Крюгер о спутнике Земли. Лунные мифы от древности до наших дней, суеверия, приливы, затмения, экспедиции "Аполлона" и планы колонизации. Научная и культурная история Луны от античных карт до лунной базы.', 499.00, '978-5-04-104202-2', 256, 1, 15, 2, FALSE, FALSE, 6700, 4500, 4.78, 2980, '/books/moon_book.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('В поисках жизни', 'Александр Панчин о возможности существования внеземной жизни. От микробов на Марсе до разумных цивилизаций — научный подход к поискам братьев по разуму. Разбор парадокса Ферми, SETI, зондов фон Неймана.', 599.00, '978-5-04-104880-2', 384, 1, 15, 2, TRUE, FALSE, 8900, 6100, 4.83, 3780, '/books/searching_life.jpg');

-- Категория: Биология и медицина (cat_id = 14)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Эгоистичный ген', 'Ричард Докинз перевернул представление об эволюции, показав, что единица отбора — не вид и не особь, а ген. Концепция "мемов" как культурных репликаторов. Одна из самых влиятельных научно-популярных книг всех времен.', 599.00, '978-5-17-119302-1', 512, 1, 14, 2, TRUE, FALSE, 14500, 10200, 4.95, 7650, '/books/selfish_gene.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Sapiens: Краткая история человечества', 'Юваль Ной Харари о трех революциях человечества: когнитивной, аграрной и научной. Как Homo sapiens стал доминирующим видом, уничтожив конкурентов и создав неолитическую экономику и империи.', 699.00, '978-5-04-104106-3', 496, 1, 14, 2, TRUE, FALSE, 19800, 14500, 4.97, 10980, '/books/sapiens.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Бесконечно ли бессмертие?', 'Борис Жуков о старении и механизмах долголетия. Почему мы стареем, кто из животных не стареет, можно ли остановить этот процесс и каковы перспективы продления жизни в XXI веке. Научный взгляд на бессмертие.', 499.00, '978-5-04-103204-3', 352, 1, 14, 2, FALSE, FALSE, 6700, 4500, 4.80, 2890, '/books/immortality.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Ген: Интимная история', 'Сиддхартха Мукерджи, онколог и писатель, прослеживает историю генетики от Менделя до CRISPR. Книга о том, как знание генома меняет медицину, правосудие и представление о человеческой природе.', 699.00, '978-5-04-092395-5', 656, 1, 14, 2, TRUE, FALSE, 8900, 6100, 4.91, 4560, '/books/gene.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Мозг и счастье', 'Лоретта Бройнинг, нейробиолог, объясняет, как биохимия мозга формирует эмоции. Дофамин, серотонин, окситоцин, эндорфин — нейромедиаторы счастья и как их прокачать без лекарств и антидепрессантов.', 550.00, '978-5-04-099811-3', 288, 1, 14, 2, TRUE, FALSE, 11200, 7800, 4.87, 5230, '/books/brain_happiness.jpg');

-- Категория: Психология (cat_id = 17)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Думай медленно... Решай быстро', 'Нобелевский лауреат Даниэль Канеман о двух системах мышления: быстрой и медленной. Объясняет когнитивные искажения, ошибки прогнозирования и почему мы переоцениваем свою рациональность.', 699.00, '978-5-17-108783-2', 704, 1, 17, 2, TRUE, FALSE, 17800, 13400, 4.96, 9870, '/books/thinking_fast_slow.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сила привычки', 'Чарльз Дюхигг о том, почему мы действуем на автопилоте и как это изменить. Петля привычки: сигнал-действие-награда. Кейсы из жизни компаний (Starbucks, Target) и спорта (олимпийский чемпион).', 550.00, '978-5-04-092204-0', 416, 1, 17, 2, TRUE, FALSE, 14500, 10200, 4.92, 6540, '/books/power_of_habit.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Выбор: О свободе и внутренней силе', 'Эдит Ева Эгер, психолог и выжившая в Освенциме, о победе над травмой и обретении себя. Книга о том, что нас определяют не события, а отношение к ним. Терапевтические истории с 50-летним стажем.', 599.00, '978-5-04-107840-3', 368, 1, 17, 2, TRUE, TRUE, 11200, 7800, 4.94, 5670, '/books/choice.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Поток: Психология оптимального переживания', 'Михай Чиксентмихайи о состоянии "потока" — полной погруженности в деятельность, приносящую радость и развитие. Как достичь счастья через творчество, работу и хобби, а не потребление.', 650.00, '978-5-04-109223-2', 480, 1, 17, 2, FALSE, FALSE, 8900, 6100, 4.88, 4230, '/books/flow.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Психология влияния', 'Роберт Чалдини о шести принципах убеждения: взаимный обмен, обязательство, социальное доказательство, авторитет, симпатия, дефицит. Книга о том, как говорить нет манипуляторам.', 499.00, '978-5-04-099430-6', 384, 1, 17, 2, TRUE, FALSE, 15600, 11200, 4.93, 7650, '/books/influence.jpg');

-- ========================================================
-- ПРИВЯЗКА КНИГ К АВТОРАМ
-- ========================================================
INSERT INTO book_authors(book_id, author_id)
    VALUES (1, 1);

INSERT INTO book_authors(book_id, author_id)
    VALUES (2, 1);

INSERT INTO book_authors(book_id, author_id)
    VALUES (3, 2);

INSERT INTO book_authors(book_id, author_id)
    VALUES (4, 2);

INSERT INTO book_authors(book_id, author_id)
    VALUES (5, 3);

INSERT INTO book_authors(book_id, author_id)
    VALUES (6, 4);

INSERT INTO book_authors(book_id, author_id)
    VALUES (7, 4);

INSERT INTO book_authors(book_id, author_id)
    VALUES (8, 5);

INSERT INTO book_authors(book_id, author_id)
    VALUES (9, 6);

INSERT INTO book_authors(book_id, author_id)
    VALUES (10, 7);

INSERT INTO book_authors(book_id, author_id)
    VALUES (11, 41);

INSERT INTO book_authors(book_id, author_id)
    VALUES (12, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (13, 14);

INSERT INTO book_authors(book_id, author_id)
    VALUES (14, 35);

INSERT INTO book_authors(book_id, author_id)
    VALUES (15, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (16, 8);

INSERT INTO book_authors(book_id, author_id)
    VALUES (17, 9);

INSERT INTO book_authors(book_id, author_id)
    VALUES (18, 10);

INSERT INTO book_authors(book_id, author_id)
    VALUES (19, 35);

INSERT INTO book_authors(book_id, author_id)
    VALUES (20, 39);

INSERT INTO book_authors(book_id, author_id)
    VALUES (21, 11);

INSERT INTO book_authors(book_id, author_id)
    VALUES (22, 12);

INSERT INTO book_authors(book_id, author_id)
    VALUES (23, 13);

INSERT INTO book_authors(book_id, author_id)
    VALUES (24, 12);

INSERT INTO book_authors(book_id, author_id)
    VALUES (25, 40);

INSERT INTO book_authors(book_id, author_id)
    VALUES (26, 22);

INSERT INTO book_authors(book_id, author_id)
    VALUES (27, 23);

INSERT INTO book_authors(book_id, author_id)
    VALUES (28, 21);

INSERT INTO book_authors(book_id, author_id)
    VALUES (29, 29);

INSERT INTO book_authors(book_id, author_id)
    VALUES (30, 30);

INSERT INTO book_authors(book_id, author_id)
    VALUES (31, 27);

INSERT INTO book_authors(book_id, author_id)
    VALUES (32, 25);

INSERT INTO book_authors(book_id, author_id)
    VALUES (33, 28);

INSERT INTO book_authors(book_id, author_id)
    VALUES (34, 27);

INSERT INTO book_authors(book_id, author_id)
    VALUES (35, 22);

INSERT INTO book_authors(book_id, author_id)
    VALUES (36, 22);

INSERT INTO book_authors(book_id, author_id)
    VALUES (37, 21);

INSERT INTO book_authors(book_id, author_id)
    VALUES (38, 34);

INSERT INTO book_authors(book_id, author_id)
    VALUES (39, 34);

INSERT INTO book_authors(book_id, author_id)
    VALUES (40, 21);

INSERT INTO book_authors(book_id, author_id)
    VALUES (41, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (42, 19);

INSERT INTO book_authors(book_id, author_id)
    VALUES (43, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (44, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (45, 18);

INSERT INTO book_authors(book_id, author_id)
    VALUES (46, 20);

INSERT INTO book_authors(book_id, author_id)
    VALUES (47, 19);

INSERT INTO book_authors(book_id, author_id)
    VALUES (48, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (49, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (50, 18);

INSERT INTO book_authors(book_id, author_id)
    VALUES (51, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (52, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (53, 18);

INSERT INTO book_authors(book_id, author_id)
    VALUES (54, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (55, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (56, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (57, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (58, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (59, 33);

INSERT INTO book_authors(book_id, author_id)
    VALUES (60, 33);

-- ========================================================
-- ПРИВЯЗКА ТЕМ К КНИГАМ (каждая книга получает 2-5 тем из своей категории)
-- ========================================================
-- Книги из категории "Русская классика" (id 2) - темы: 45,46,47,17,21
INSERT INTO book_topics(book_id, topic_id)
    VALUES (1, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (1, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (1, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (2, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (2, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (2, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (3, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (3, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (3, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (4, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (4, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (4, 46);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (5, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (5, 48);

-- Книги из категории "Зарубежная классика" (id 3) - темы: 45,41,47,40,17
INSERT INTO book_topics(book_id, topic_id)
    VALUES (6, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (6, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (6, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (7, 48);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (7, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (8, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (8, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (9, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (9, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (9, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (10, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (10, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (10, 17);

-- Книги из категории "Современная проза" (id 4) - темы: 40,47,21,23,22
INSERT INTO book_topics(book_id, topic_id)
    VALUES (11, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (11, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (12, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (12, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (12, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (13, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (13, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (13, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (14, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (14, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (14, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (15, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (15, 43);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (15, 45);

-- Книги из категории "Фантастика и фэнтези" (id 5) - темы: 33,34,35,36,37
INSERT INTO book_topics(book_id, topic_id)
    VALUES (16, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (16, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (17, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (17, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (17, 35);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (18, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (18, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (19, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (19, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (19, 44);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (20, 36);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (20, 37);

-- Книги из категории "Детективы и триллеры" (id 6) - темы: 38,39,49,21,8
INSERT INTO book_topics(book_id, topic_id)
    VALUES (21, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (21, 39);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (21, 49);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (22, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (22, 39);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (23, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (24, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (25, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (25, 17);

-- Книги из категории "Бизнес и менеджмент" (id 8) - темы: 29,30,31,32,24
INSERT INTO book_topics(book_id, topic_id)
    VALUES (26, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (26, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (27, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (27, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (28, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (28, 31);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (29, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (29, 30);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (30, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (30, 31);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (30, 24);

-- Книги из категории "Маркетинг и реклама" (id 9) - темы: 25,26,21,30,1
INSERT INTO book_topics(book_id, topic_id)
    VALUES (31, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (31, 26);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (32, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (32, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (33, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (33, 24);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (34, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (34, 26);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (35, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (35, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (35, 1);

-- Книги из категории "Финансы и инвестиции" (id 10) - темы: 27,28,29,1,8
INSERT INTO book_topics(book_id, topic_id)
    VALUES (36, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (36, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (37, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (37, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (37, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (38, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (38, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (39, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (39, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (40, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (40, 1);

-- Книги из категории "Карьера и саморазвитие" (id 11) - темы: 22,23,24,21,32
INSERT INTO book_topics(book_id, topic_id)
    VALUES (41, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (41, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (41, 24);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (42, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (42, 24);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (43, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (43, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (43, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (44, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (44, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (45, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (45, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (45, 24);

-- Книги из категории "Физика и математика" (id 13) - темы: 1,2,9,10,11
INSERT INTO book_topics(book_id, topic_id)
    VALUES (46, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (46, 2);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (46, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (47, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (47, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (48, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (48, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (48, 10);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (49, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (49, 11);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (50, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (50, 2);

-- Книги из категории "Космос и астрономия" (id 15) - темы: 9,10,11,12,36
INSERT INTO book_topics(book_id, topic_id)
    VALUES (51, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (51, 10);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (51, 11);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (52, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (52, 10);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (53, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (53, 11);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (54, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (54, 12);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (55, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (55, 10);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (55, 11);

-- Книги из категории "Биология и медицина" (id 14) - темы: 13,14,15,16,21
INSERT INTO book_topics(book_id, topic_id)
    VALUES (56, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (56, 16);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (57, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (57, 14);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (57, 16);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (58, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (58, 15);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (59, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (59, 14);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (60, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (60, 15);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (60, 21);

-- Книги из категории "Психология" (id 17) - темы: 21,22,15,23,32
INSERT INTO book_topics(book_id, topic_id)
    VALUES (61, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (61, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (62, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (62, 24);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (63, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (63, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (63, 23);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (64, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (64, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (65, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (65, 32);

-- ========================================================
-- ДОПОЛНИТЕЛЬНЫЕ КНИГИ для достижения 100+ книг
-- ========================================================
-- Детская литература (категория 18, подкатегории 19,20,21,22)
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Волшебник Изумрудного города', 'Сказочная повесть Александра Волкова о девочке Элли и её друзьях Страшиле, Железном Дровосеке и Трусливом Льве, которые идут к Гудвину, чтобы исполнить свои заветные желания.', 399.00, '978-5-04-092345-0', 224, 1, 19, 7, TRUE, FALSE, 8900, 6700, '/books/wizard_oz.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Приключения Незнайки', 'Книга Николая Носова о приключениях коротышек из Цветочного города, главный из которых — хвастливый и любопытный Незнайка, постоянно попадающий в забавные переделки.', 350.00, '978-5-04-092871-4', 192, 1, 20, 7, TRUE, FALSE, 7800, 5600, '/books/dunno_adventures.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Детская энциклопедия о динозаврах', 'Красочная энциклопедия с реалистичными иллюстрациями и удивительными фактами о мире динозавров. Для детей младшего и среднего школьного возраста.', 599.00, '978-5-04-099888-5', 128, 1, 21, 7, FALSE, TRUE, 5600, 3400, '/books/dinosaurs_encyclopedia.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Комиксы Marvel: Мстители', 'Сборник классических комиксов о супергероях Marvel: Железный человек, Тор, Капитан Америка и Халк объединяются, чтобы спасти Землю от инопланетного вторжения.', 450.00, '978-5-04-099123-7', 96, 1, 22, 9, FALSE, TRUE, 6700, 4500, '/books/avengers_comics.jpg');

-- Еще книги по другим категориям
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Python для начинающих', 'Практическое руководство по языку программирования Python. От установки и основ синтаксиса до создания веб-приложений и работы с базами данных. Примеры и упражнения для самостоятельной работы.', 699.00, '978-5-04-099456-7', 384, 2, 13, 4, TRUE, FALSE, 12300, 8900, '/books/python_for_beginners.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Искусство программирования', 'Фундаментальный труд Дональда Кнута об алгоритмах и структурах данных. Том 1: Основные алгоритмы. Классика computer science.', 1250.00, '978-5-04-097234-2', 720, 1, 13, 4, FALSE, FALSE, 8900, 3400, '/books/art_programming.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('История России с древнейших времен', 'Многотомный труд Сергея Соловьева, охватывающий историю России от Рюрика до конца XVIII века. Академическое издание для студентов и всех интересующихся историей.', 899.00, '978-5-04-092456-3', 896, 1, 16, 10, FALSE, FALSE, 4500, 2300, '/books/history_russia.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Психология денег', 'Книга Моргана Хаузела о том, как психологические особенности влияют на финансовые решения. Деньги — это не математика, а поведение. 20 уроков об управлении капиталом.', 550.00, '978-5-04-109839-5', 288, 1, 10, 2, TRUE, FALSE, 11200, 7800, '/books/psychology_money.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, picture_url)
    VALUES ('Криптономикон', 'Фантастический роман Нила Стивенсона о криптографии, Второй мировой войне и создании цифровой валюты. Альтернативная история и технотриллер.', 699.00, '978-5-04-099876-2', 1152, 1, 5, 2, FALSE, FALSE, 6700, 3400, '/books/cryptonomicon.jpg');

SELECT
    count(*)
FROM
    books;

-- Привязка авторов к дополнительным книгам
INSERT INTO book_authors(book_id, author_id)
    VALUES (66, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (67, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (68, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (69, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (70, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (71, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (72, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (73, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (74, 50);

-- Темы для дополнительных книг
INSERT INTO book_topics(book_id, topic_id)
    VALUES (66, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (66, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (67, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (67, 42);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (68, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (68, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (69, 13);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (69, 14);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (70, 3);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (70, 4);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (71, 3);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (71, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (72, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (72, 18);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (73, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (73, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (74, 36);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (74, 37);

-- ========================================================
-- ДОБАВЛЕНИЕ НОВЫХ АВТОРОВ (20 штук)
-- ========================================================
INSERT INTO authors(name, bio, picture_url)
    VALUES ('Эрих Мария Ремарк', 'Немецкий писатель, автор романов о "потерянном поколении"', '/authors/remarque.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джером Д. Сэлинджер', 'Американский писатель, автор культового романа "Над пропастью во ржи"', '/authors/salinger.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Умберто Эко', 'Итальянский писатель, философ, историк-медиевист', '/authors/eco.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Милан Кундера', 'Чешский и французский писатель, эссеист', '/authors/kundera.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Джон Фаулз', 'Английский писатель, постмодернист', '/authors/fowles.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Курт Воннегут', 'Американский писатель-сатирик', '/authors/vonnegut.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Пауло Коэльо', 'Бразильский писатель, автор романа "Алхимик"', '/authors/coelho.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Харуки Мураками', 'Японский писатель, переводчик', '/authors/murakami.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Томас Пинчон', 'Американский писатель-постмодернист', '/authors/pynchon.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Донна Тартт', 'Американская писательница, лауреат Пулитцеровской премии', '/authors/tartt.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Евгений Водолазкин', 'Русский писатель, филолог, автор "Лавра"', '/authors/vodolazkin.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Гузель Яхина', 'Российская писательница, автор "Зулейха открывает глаза"', '/authors/yakhina.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Алексей Иванов', 'Российский писатель, автор "Географа глобус пропил"', '/authors/ivanov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Дмитрий Глуховский', 'Российский писатель и журналист, автор "Метро 2033"', '/authors/glukhovsky.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Сергей Лукьяненко', 'Российский писатель-фантаст, автор "Ночного дозора"', '/authors/lukyanenko.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Мария Семёнова', 'Российская писательница, автор "Волкодава"', '/authors/semenova.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Ник Перумов', 'Российский писатель-фантаст, продолжатель традиций Толкина', '/authors/perumov.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Татьяна Толстая', 'Русская писательница, автор романа "Кысь"', '/authors/tolstaya.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Людмила Улицкая', 'Русская писательница, лауреат премии "Русский Букер"', '/authors/ulitskaya.jpg');

INSERT INTO authors(name, bio, picture_url)
    VALUES ('Захар Прилепин', 'Российский писатель, публицист', '/authors/prilepin.jpg');

-- ========================================================
-- НОВЫЕ КНИГИ (80 штук)
-- ========================================================
-- Категория: Русская классика (cat_id = 2) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Мёртвые души', 'Поэма Николая Гоголя о предприимчивом авантюристе Чичикове, который скупает "мёртвые души" — умерших крестьян, числящихся живыми по ревизским сказкам. Сатирическое изображение помещичьей России, галерея ярких типов от Манилова до Плюшкина, философские отступления о судьбе России. Шедевр русской литературы, не имеющий аналогов по глубине и юмору.', 499.00, '978-5-04-098654-7', 352, 1, 2, 1, TRUE, FALSE, 8900, 5600, 4.82, 3450, '/books/dead_souls.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Герой нашего времени', 'Роман Михаила Лермонтова о "лишнем человеке" Григории Печорине — умном, талантливом, но не находящем применения своим способностям офицере, приносящем несчастье окружающим. Психологический портрет целого поколения, размышления о дружбе, любви, судьбе и смысле жизни. Первый русский психологический роман.', 399.00, '978-5-04-092338-2', 224, 1, 2, 2, TRUE, FALSE, 7800, 4900, 4.85, 2980, '/books/hero_of_our_time.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Отцы и дети', 'Роман Ивана Тургенева о конфликте поколений и идеологий. Молодой нигилист Евгений Базаров отрицает всё: искусство, любовь, авторитеты. Его столкновение с братьями Кирсановыми и трагическая любовь к Анне Одинцовой становятся испытанием его убеждений. Книга о вечном противостоянии отцов и детей.', 399.00, '978-5-04-092346-7', 288, 1, 2, 2, TRUE, FALSE, 6700, 4300, 4.79, 2670, '/books/fathers_sons.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Обломов', 'Роман Ивана Гончарова о дворянине Илье Ильиче Обломове, который большую часть жизни проводит на диване в халате, не в силах решиться на какие-либо действия. История его дружбы с деятельным Штольцем и трагической любви к Ольге Ильинской. Книга о "обломовщине" как национальном феномене.', 450.00, '978-5-04-092339-9', 544, 1, 2, 2, FALSE, FALSE, 5600, 3400, 4.76, 2340, '/books/oblamov.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Чайка', 'Пьеса Антона Чехова о людях искусства — писателях и актёрах, их любви, ревности, творческих поисках и разочарованиях. Новаторское произведение, где действие строится не на внешних событиях, а на внутренних переживаниях героев. Знаменитая "Чайка" как символ разбитой мечты.', 299.00, '978-5-04-092345-3', 160, 2, 2, 5, FALSE, FALSE, 4500, 2800, 4.71, 1980, '/books/seagull.jpg');

-- Категория: Зарубежная классика (cat_id = 3) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Три товарища', 'Роман Эриха Марии Ремарка о трёх друзьях — ветеранах Первой мировой войны, которые открывают авторемонтную мастерскую в Берлине 1920-х годов. История дружбы, любви и выживания в трудные времена. Главный герой Роберт Локамп встречает Патрицию Хольцман, и их любовь становится испытанием для всех троих.', 550.00, '978-5-04-098789-6', 544, 1, 3, 2, TRUE, FALSE, 13400, 9800, 4.93, 5670, '/books/three_comrades.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Над пропастью во ржи', 'Культовый роман Джерома Д. Сэлинджера о подростке Холдене Колфилде, который после исключения из школы бродит по Нью-Йорку. Монолог юноши, разочарованного во взрослом мире и его лицемерии. Книга о бунте, одиночестве, взрослении и желании спасти детей от падения "в пропасть".', 450.00, '978-5-04-099234-0', 288, 2, 3, 2, TRUE, FALSE, 15600, 11200, 4.89, 6540, '/books/catcher_in_rye.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Имя розы', 'Интеллектуальный детектив Умберто Эко, действие которого происходит в средневековом итальянском монастыре. Францисканский монах Вильгельм Баскервильский расследует серию загадочных убийств, связанных с запретной книгой Аристотеля о комедии. Роман о вере, разуме, власти и силе слова.', 699.00, '978-5-04-098998-2', 624, 1, 3, 2, TRUE, FALSE, 11200, 7800, 4.94, 4560, '/books/name_of_rose.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Невыносимая лёгкость бытия', 'Философский роман Милана Кундеры о любви, свободе и выборе. История отношений хирурга Томаша, его жены Терезы и художницы Сабины на фоне пражской весны 1968 года. Размышления о лёгкости и тяжести бытия, о том, что каждый выбор навсегда закрывает другие возможности.', 499.00, '978-5-04-099567-6', 448, 1, 3, 2, FALSE, FALSE, 8900, 5600, 4.87, 3450, '/books/unbearable_lightness.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Коллекционер', 'Психологический триллер Джона Фаулза о молодом клерке Фредерике, который, выиграв крупную сумму в футбольном тотализаторе, похищает прекрасную искусствоведку Миранду и держит её в подвале своего уединённого дома. История о любви, ставшей одержимостью, о природе зла и столкновении миров.', 499.00, '978-5-04-099123-8', 384, 1, 3, 2, TRUE, FALSE, 10300, 7200, 4.86, 3980, '/books/collector.jpg');

-- Категория: Современная проза (cat_id = 4) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Бойня номер пять', 'Автобиографический роман Курта Воннегута о бомбардировке Дрездена во время Второй мировой войны. Главный герой Билли Пилигрим "выпал из времени" и путешествует между разными периодами своей жизни: войной, послевоенной Америкой и инопланетной планетой Тральфамадор. Антивоенная сатира.', 499.00, '978-5-04-098765-0', 320, 1, 4, 2, TRUE, FALSE, 11800, 8400, 4.90, 4560, '/books/slaughterhouse_five.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Алхимик', 'Философская притча Пауло Коэльо о пастухе Сантьяго, который отправляется из Испании в египетскую пустыню в поисках сокровища у пирамид. По пути он встречает короля, цыганку, алхимика и учится слушать своё сердце. Книга о следовании за мечтой и языке мира.', 399.00, '978-5-04-099234-5', 224, 1, 4, 2, TRUE, FALSE, 17800, 13400, 4.88, 7890, '/books/alchemist.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('О дивный новый мир', 'Антиутопия Олдоса Хаксли о мире будущего, где люди рождаются в пробирках, генетически модифицируются для выполнения определённой работы и с детства программируются на счастье с помощью наркотика "сомы". "Дикарь" Джон из резервации сталкивается с этим обществом.', 499.00, '978-5-04-098456-7', 384, 1, 4, 2, TRUE, FALSE, 14500, 10200, 4.92, 5670, '/books/brave_new_world.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Лавр', 'Роман Евгения Водолазкина о средневековом русском лекаре Арсении, который после смерти любимой девушки Устины отправляется в паломничество по святым местам, исцеляя больных. Книга о любви, грехе, покаянии и пути к святости. Современная житийная литература.', 599.00, '978-5-04-099876-3', 448, 1, 4, 2, TRUE, TRUE, 8900, 6200, 4.94, 3980, '/books/laurus.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Зулейха открывает глаза', 'Роман Гузель Яхиной о судьбе татарской крестьянки Зулейхи, которая во время раскулачивания теряет мужа и попадает в ссылку в Сибирь на строительство электростанции. История выживания, женской силы и обретения новой жизни. Лауреат премии "Большая книга".', 550.00, '978-5-04-099345-6', 512, 1, 4, 2, TRUE, FALSE, 12300, 8700, 4.91, 5230, '/books/zuleikha.jpg');

-- Категория: Фантастика и фэнтези (cat_id = 5) - добавляем 10 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Метро 2033', 'Постапокалиптический роман Дмитрия Глуховского о мире после ядерной войны, где выжившие люди живут в московском метро. Главный герой Артём должен пройти через всё метро, чтобы спасти свою станцию от таинственных мутантов. Мрачная атмосфера и философские размышления.', 499.00, '978-5-04-099234-8', 416, 1, 5, 2, TRUE, FALSE, 14500, 10900, 4.89, 6780, '/books/metro_2033.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Ночной дозор', 'Первый роман Сергея Лукьяненко из цикла "Дозоры". В мире существуют Иные — маги, оборотни, вампиры, разделившиеся на Светлых и Тёмных. Московский Ночной Дозор следит за соблюдением равновесия. Главный герой Антон Городецкий сталкивается с пророчеством о конце мира.', 450.00, '978-5-04-099345-9', 448, 1, 5, 2, TRUE, FALSE, 11200, 7800, 4.87, 4560, '/books/night_watch.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Волкодав', 'Героическое фэнтези Марии Семёновой о воине из рода Серого Пса, последнем выжившем после уничтожения его племени. Волкодав вырос в рудниках, бежал, стал великим воином и отправляется на поиски справедливости. Славянское фэнтези с глубокой проработкой мира.', 550.00, '978-5-04-099456-8', 544, 1, 5, 2, TRUE, FALSE, 8900, 6200, 4.91, 3980, '/books/wolfhound.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Кольцо Тьмы', 'Роман Ника Перумова, продолжающий традиции Толкина. Действие происходит в Средиземье после Войны Кольца. Новый герой — хоббит Фолко Брендибак — находит древнее кольцо и сталкивается с пробуждающимся злом. Эпичное фэнтези.', 499.00, '978-5-04-099567-9', 512, 1, 5, 2, FALSE, FALSE, 6700, 4300, 4.82, 2890, '/books/ring_of_darkness.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Дюна', 'Эпический научно-фантастический роман Фрэнка Герберта о пустынной планете Арракис, единственном источнике пряности — самого ценного вещества во Вселенной. Дом Атрейдесов получает контроль над Арракисом, но подвергается предательству. Сын герцога Пол должен стать лидером фрименов.', 699.00, '978-5-04-099678-9', 720, 1, 5, 2, TRUE, FALSE, 15600, 11200, 4.96, 7650, '/books/dune.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Автостопом по Галактике', 'Юмористическая фантастика Дугласа Адамса о приключениях землянина Артура Дента, которого его друг Форд Префект спасает с Земли за минуту до её уничтожения. Путешествие по Галактике, поиск ответа на главный вопрос жизни и компьютер Deep Thought.', 450.00, '978-5-04-099789-5', 288, 1, 5, 2, TRUE, FALSE, 12300, 8900, 4.93, 5670, '/books/hitchhikers_galaxy.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Солярис', 'Философская фантастика Станислава Лема о планете Солярис, покрытой мыслящим океаном. Психолог Крис Кельвин прибывает на станцию, изучающую океан, и сталкивается с материализацией своих воспоминаний и чувства вины. Книга о невозможности понять чужой разум.', 499.00, '978-5-04-099890-8', 384, 1, 5, 2, FALSE, FALSE, 8900, 5600, 4.88, 3450, '/books/solaris.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Страна радости', 'Роман Стивена Кинга о студенте Девине Джонсе, который устраивается на работу в парк аттракционов "Страна радости". Летом 1973 года он расследует убийство, произошедшее в парке много лет назад, и встречает призрак девушки Линды. Ностальгический мистический детектив.', 550.00, '978-5-04-099901-1', 512, 1, 5, 2, TRUE, FALSE, 10300, 7200, 4.85, 4120, '/books/joyland.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Оно', 'Эпический роман ужасов Стивена Кинга о существе, которое просыпается каждые 27 лет в городе Дерри, принимая облик клоуна Пеннивайза. Семеро детей, победивших монстра в детстве, возвращаются взрослыми для финальной битвы. Книга о дружбе, памяти и детских страхах.', 699.00, '978-5-04-099012-9', 1376, 1, 5, 2, TRUE, TRUE, 16700, 12300, 4.97, 8760, '/books/it.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Джонатан Стрендж и мистер Норрелл', 'Магический исторический роман Сюзанны Кларк о возрождении магии в Англии XIX века. Два волшебника — затворник Норрелл и амбициозный Стрендж — пытаются вернуть магию, но их соперничество приводит к трагическим последствиям.', 699.00, '978-5-04-099123-0', 864, 1, 5, 2, FALSE, FALSE, 7800, 4900, 4.89, 3450, '/books/jonathan_strange.jpg');

-- Категория: Детективы и триллеры (cat_id = 6) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Убить пересмешника', 'Роман Харпер Ли о маленькой девочке Глазастик (Скаут) Финч, живущей в вымышленном городе Мейкомб, Алабама, в 1930-е годы. Её отец Аттикус, адвокат, защищает чернокожего мужчину, ложно обвинённого в изнасиловании. Книга о расизме, справедливости и взрослении.', 499.00, '978-5-04-099234-1', 384, 1, 6, 2, TRUE, FALSE, 13400, 9800, 4.95, 6540, '/books/to_kill_mockingbird.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Молчание ягнят', 'Психологический триллер Томаса Харриса о молодой сотруднице ФБР Кларисе Старлинг, которая для поимки серийного убийцы Баффало Билла обращается за помощью к гениальному психиатру-каннибалу доктору Ганнибалу Лектеру. Опасная игра разумов.', 550.00, '978-5-04-099345-7', 416, 1, 6, 2, TRUE, FALSE, 11800, 8400, 4.94, 5230, '/books/silence_lambs.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Девушка с татуировкой дракона', 'Первый роман Стига Ларссона из трилогии "Миллениум". Журналист Микаэль Блумквист расследует исчезновение девушки из семьи промышленников. Ему помогает хакер Лисбет Саландер с татуировкой дракона. Скандинавский нуар о секретах и насилии.', 599.00, '978-5-04-099456-3', 672, 1, 6, 2, TRUE, FALSE, 14500, 10200, 4.92, 5670, '/books/girl_dragon_tattoo.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Секретные материалы', 'Роман по мотивам культового сериала о агентах ФБР Малдере и Скалли, расследующих необъяснимые паранормальные явления. Новое дело: серия убийств, где каждый свидетель видит разное лицо убийцы.', 450.00, '978-5-04-099567-8', 384, 1, 6, 2, FALSE, FALSE, 5600, 3400, 4.76, 2340, '/books/xfiles.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Остров проклятых', 'Психологический триллер Денниса Лехейна о двух маршалах США, прибывающих на остров, где расположена психиатрическая клиника для особо опасных преступников. Исчезнувшая пациентка, странные врачи и тайны прошлого.', 550.00, '978-5-04-099078-9', 416, 1, 6, 2, TRUE, FALSE, 9800, 6700, 4.88, 4120, '/books/shutter_island.jpg');

-- Категория: Деловая литература (cat_id = 8) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Новая поведенческая экономика', 'Ричард Талер, лауреат Нобелевской премии, о том, как психология влияет на экономические решения. Книга о "подталкивании" — мягком влиянии на выбор людей. Как создать систему, где легко делать правильные финансовые решения.', 599.00, '978-5-04-099789-8', 416, 1, 8, 3, TRUE, FALSE, 8900, 5600, 4.87, 3450, '/books/nudge.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Zero to One', 'Питер Тиль, сооснователь PayPal и первый инвестор Facebook, о том, как создавать компании, которые делают что-то принципиально новое. Монополия как цель стартапа, секреты и будущее технологий.', 599.00, '978-5-04-099890-9', 240, 1, 8, 3, TRUE, FALSE, 11200, 7800, 4.94, 4560, '/books/zero_to_one.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Бизнес с нуля', 'Эрик Рис о методологии бережливого стартапа. Как быстро проверять гипотезы, создавая минимально жизнеспособный продукт, и итеративно его улучшать. Книга для основателей стартапов и менеджеров.', 650.00, '978-5-04-099901-2', 320, 1, 8, 3, TRUE, FALSE, 10300, 7200, 4.91, 4120, '/books/lean_startup.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Принципы', 'Рэй Далио, основатель крупнейшего хедж-фонда Bridgewater, о принципах управления и принятия решений. Система радикальной прозрачности и поиска лучших ответов. Книга для лидеров и предпринимателей.', 699.00, '978-5-04-099012-8', 608, 1, 8, 3, TRUE, FALSE, 11800, 8400, 4.93, 5230, '/books/principles.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('От нуля к единице', 'Продолжение бестселлера Питера Тиля с дополнительными главами о будущем технологий, искусственного интеллекта и энергетики. Как создавать инновации, которые меняют мир.', 550.00, '978-5-04-099123-1', 256, 1, 8, 3, FALSE, TRUE, 6700, 4300, 4.84, 2890, '/books/zero_to_one_extended.jpg');

-- Категория: Маркетинг и реклама (cat_id = 9) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Взлом маркетинга', 'Фил Барден о прикладной нейробиологии в маркетинге. Почему одни рекламные ролики работают, а другие нет. Влияние бессознательного на покупательские решения. Как использовать знания о мозге в рекламе.', 599.00, '978-5-04-099234-2', 352, 1, 9, 2, TRUE, FALSE, 7800, 4900, 4.86, 3120, '/books/hacking_marketing_neuro.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Трафик: Как заставить людей заходить на сайт', 'Практическое руководство по привлечению посетителей на сайт. SEO, контент-маркетинг, SMM, email-маркетинг. Автор делится реальными кейсами и проверенными стратегиями.', 550.00, '978-5-04-099343-9', 384, 1, 9, 2, FALSE, FALSE, 5600, 3400, 4.74, 2340, '/books/traffic.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Лидовый маркетинг', 'Стратегии генерации лидов для B2B и B2C. Как превратить посетителей в клиентов. Воронка продаж, квалификация лидов, автоматизация маркетинга. Книга для маркетологов и предпринимателей.', 599.00, '978-5-04-099456-5', 320, 1, 9, 2, FALSE, FALSE, 4900, 3100, 4.71, 1980, '/books/lead_marketing.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сторителлинг в маркетинге', 'Как использовать силу историй для продвижения бренда. Искусство рассказывать истории, которые запоминаются и вызывают эмоции. Техники сторителлинга от ведущих мировых брендов.', 499.00, '978-5-04-099067-9', 288, 1, 9, 2, FALSE, FALSE, 6700, 4500, 4.81, 2890, '/books/storytelling_marketing.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Контент-стратегия', 'Системный подход к созданию контента для бизнеса. Как анализировать аудиторию, планировать контент, измерять эффективность. Книга для контент-маркетологов и редакторов.', 550.00, '978-5-04-099678-8', 352, 1, 9, 2, FALSE, FALSE, 5800, 3600, 4.77, 2450, '/books/content_strategy.jpg');

-- Категория: Финансы и инвестиции (cat_id = 10) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Инвестиции: Путеводитель от Уоррена Баффетта', 'Сборник писем Уоррена Баффетта к акционерам Berkshire Hathaway с комментариями экспертов. Принципы стоимостного инвестирования, долгосрочного владения и анализа бизнеса. Библия инвестора.', 699.00, '978-5-04-099789-9', 512, 1, 10, 2, TRUE, FALSE, 12300, 8900, 4.95, 5670, '/books/buffett_letters.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Деньги делают деньги', 'Книга о стратегиях создания капитала для начинающих. От первых инвестиций до пассивного дохода. Риски, диверсификация, психология инвестора. Практические советы без сложных терминов.', 550.00, '978-5-04-099810-9', 320, 1, 10, 2, TRUE, FALSE, 10300, 7200, 4.88, 4560, '/books/money_makes_money.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Финансовая свобода', 'Грант Сабатье о пути к финансовой независимости через агрессивные инвестиции и минимизацию расходов. Концепция FIRE (Financial Independence, Retire Early). Как накопить капитал и выйти на пенсию рано.', 599.00, '978-5-04-099901-0', 384, 1, 10, 2, TRUE, FALSE, 11800, 8400, 4.91, 5230, '/books/financial_freedom.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Антихрупкость', 'Нассим Талеб о системах, которые становятся сильнее от хаоса и стресса. Книга о том, как построить жизнь, бизнес и инвестиции, чтобы выигрывать от неопределённости мира.', 699.00, '978-5-13-099012-8', 768, 1, 10, 2, TRUE, FALSE, 14500, 10200, 4.96, 6540, '/books/antifragile.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Богатство семьи', 'Как передавать финансовые знания детям, создавать семейный капитал и избегать конфликтов. Инвестиции, наследство, финансовое планирование на поколения вперёд.', 550.00, '978-5-04-099123-4', 352, 1, 10, 2, FALSE, TRUE, 6700, 4300, 4.83, 2980, '/books/family_wealth.jpg');

-- Категория: Карьера и саморазвитие (cat_id = 11) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('7 навыков высокоэффективных людей', 'Стивен Кови о семи принципах личной эффективности: проактивность, начиная с конечной цели, сначала делай главное, мышление "выиграл/выиграл", сначала понять, потом быть понятым, синергия и постоянное обновление.', 599.00, '978-5-04-099234-3', 384, 1, 11, 2, TRUE, FALSE, 15600, 11200, 4.97, 8760, '/books/7_habits.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Выйди из зоны комфорта', 'Брайан Трейси о 21 методе повышения личной эффективности. Тайм-менеджмент, целеполагание, преодоление прокрастинации. Как сделать больше за меньшее время и достигать целей.', 499.00, '978-5-04-099313-7', 288, 1, 11, 2, TRUE, FALSE, 13400, 9800, 4.92, 5670, '/books/out_of_comfort_zone.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Гибкое сознание', 'Кэрол Дуэк о двух типах мышления: фиксированном (талант дан от природы) и гибком (способности развиваются). Книга о том, как изменить мышление, чтобы достигать большего в жизни.', 550.00, '978-5-04-099156-8', 336, 1, 11, 2, TRUE, FALSE, 11800, 8400, 4.94, 5230, '/books/mindset.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Монах, который продал свой "Феррари"', 'Притча Робина Шармы о поиске счастья и смысла жизни. Успешный адвокат после сердечного приступа отправляется в Гималаи, где встречает монахов, обучающих его мудрости.', 450.00, '978-5-14-099567-9', 256, 1, 11, 2, TRUE, FALSE, 10300, 7200, 4.89, 4560, '/books/monk_sold_ferrari.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Не навреди', 'Генри Марш, нейрохирург, о своей работе — операциях на мозге, рисках и ошибках. Мемуары о жизни и смерти, о том, как принимать трудные решения и жить с их последствиями.', 599.00, '978-5-04-099671-8', 384, 1, 11, 2, FALSE, FALSE, 7800, 4900, 4.86, 3450, '/books/do_no_harm.jpg');

-- Категория: Научпоп - Физика и математика (cat_id = 13) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Теория всего', 'Стивен Хокинг о происхождении и судьбе Вселенной. От Большого взрыва до чёрных дыр. Сборник лекций гениального физика, где он излагает свои теории простым языком для всех.', 499.00, '978-5-04-019789-9', 176, 1, 13, 2, TRUE, FALSE, 11200, 7800, 4.93, 5230, '/books/theory_of_everything.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Физика будущего', 'Митио Каку о том, какие технологии ждут нас через 20, 50 и 100 лет. Компьютеры, искусственный интеллект, космические путешествия, биотехнологии. Прогнозы от ведущего физика.', 599.00, '978-5-04-099190-9', 480, 1, 13, 2, TRUE, FALSE, 9800, 6700, 4.90, 4120, '/books/physics_of_future.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Тайная опора', 'Книга о привязанности в жизни ребёнка от психолога Людмилы Петрановской. Как формируется доверие к миру, почему важны объятия и как поддерживать детей в трудных ситуациях.', 499.00, '978-5-04-091901-2', 320, 1, 13, 2, TRUE, FALSE, 14500, 10200, 4.96, 6540, '/books/secret_support.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Вселенная из ничего', 'Лоуренс Краусс о том, как Вселенная могла возникнуть из ничего без вмешательства творца. Квантовая физика, теория струн и мультивселенная. Научный взгляд на происхождение мира.', 550.00, '978-5-04-059012-8', 288, 1, 13, 2, FALSE, FALSE, 7800, 4900, 4.85, 3120, '/books/universe_from_nothing.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Элегантная вселенная', 'Брайан Грин о теории струн — самой многообещающей кандидате на "теорию всего". Объяснение сложнейшей физики на пальцах: дополнительные измерения, параллельные вселенные.', 599.00, '978-5-04-099523-5', 448, 1, 13, 2, TRUE, FALSE, 8900, 5600, 4.91, 3980, '/books/elegant_universe.jpg');

-- Категория: Биология и медицина (cat_id = 14) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Краткая история эволюции', 'Ричард Докинз о происхождении видов, естественном отборе и эволюции человека. Книга для тех, кто хочет понять основы биологии и доказательства эволюции.', 550.00, '978-5-04-091234-4', 320, 1, 14, 2, TRUE, FALSE, 10300, 7200, 4.92, 4560, '/books/brief_evolution.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Homo Deus: Краткая история завтра', 'Юваль Ной Харари о будущем человечества. Что станет с человеком, когда мы научимся побеждать старость, смерть и болезни? Книга о новых вызовах XXI века.', 699.00, '978-5-04-099345-8', 512, 1, 14, 2, TRUE, FALSE, 16700, 12300, 4.97, 8760, '/books/homo_deus.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Биология добра и зла', 'Роберт Сапольски о нейробиологии поведения. Почему люди совершают хорошие и плохие поступки? Влияние генов, гормонов, воспитания и культуры на моральный выбор.', 799.00, '978-5-04-099450-8', 832, 1, 14, 2, TRUE, FALSE, 13400, 9800, 4.95, 5980, '/books/biology_evil.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Сам себе плацебо', 'Джо Диспенза о силе мысли и самовнушении. Как наши убеждения меняют физиологию, исцеляют болезни и создают новую реальность. Нейропластичность и сознание.', 599.00, '978-5-04-094567-9', 496, 1, 14, 2, FALSE, FALSE, 8900, 5600, 4.87, 3450, '/books/placebo.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Время гениев', 'Книга об учёных, изменивших мир: Дарвин, Ньютон, Эйнштейн, Кюри. Их открытия, борьба за признание и влияние на науку. Вдохновляющие биографии для подростков и взрослых.', 499.00, '978-3-04-099678-8', 384, 1, 14, 2, FALSE, TRUE, 6700, 4300, 4.82, 2890, '/books/time_of_geniuses.jpg');

-- Категория: Космос и астрономия (cat_id = 15) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Астрономия для всех', 'Владимир Сурдин о звёздах, планетах и галактиках для начинающих. Как наблюдать за небом, что можно увидеть в любительский телескоп и как устроена Вселенная.', 550.00, '978-5-04-019789-8', 352, 1, 15, 2, TRUE, FALSE, 8900, 5600, 4.88, 4120, '/books/astronomy_for_all.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Черные дыры. Лекции', 'Стивен Хокинг о чёрных дырах — самых загадочных объектах во Вселенной. Излучение Хокинга, потеря информации и парадоксы. Последние научные взгляды гения.', 499.00, '978-5-04-099120-9', 176, 1, 15, 2, TRUE, FALSE, 10300, 7200, 4.94, 4560, '/books/black_holes_lectures.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Загадки Марса', 'Книга о Красной планете: история открытий, марсоходы, поиски воды и жизни. Почему Марс теряет атмосферу и возможна ли его колонизация? Научные данные с миссий NASA.', 550.00, '978-5-04-049901-2', 288, 1, 15, 2, FALSE, FALSE, 7800, 4900, 4.85, 3120, '/books/mars_mysteries.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Поиск жизни во Вселенной', 'От микробов до цивилизаций — научный взгляд на возможность существования внеземной жизни. SETI, экзопланеты и проекты поиска инопланетного разума.', 599.00, '978-5-04-099014-8', 384, 1, 15, 2, FALSE, FALSE, 6700, 4500, 4.84, 2980, '/books/search_life_universe.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Солнечная система', 'Путеводитель по планетам, их спутникам и малым телам. Интересные факты, фотографии с космических аппаратов и новейшие открытия астрономии.', 499.00, '978-5-04-099123-6', 256, 1, 15, 2, FALSE, FALSE, 5600, 3400, 4.79, 2450, '/books/solar_system.jpg');

-- Категория: Психология (cat_id = 17) - добавляем 5 книг
INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Парадокс перфекциониста', 'Тал Бен-Шахар, профессор психологии Гарварда, о вреде перфекционизма. Как научиться радоваться процессу, принимать несовершенство и жить полной жизнью.', 550.00, '978-5-04-099434-5', 304, 1, 17, 2, TRUE, FALSE, 8900, 5600, 4.86, 3450, '/books/perfectionist_paradox.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Эмоциональный интеллект', 'Дэниел Гоулман о том, почему умение управлять эмоциями важнее IQ. Как распознавать свои и чужие чувства, контролировать импульсы и строить отношения.', 599.00, '978-5-04-049345-8', 512, 1, 17, 2, TRUE, FALSE, 14500, 10200, 4.95, 6540, '/books/emotional_intelligence.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Поток: Психология оптимального опыта', 'Михай Чиксентмихайи о счастье как побочном продукте деятельности, полностью поглощающей человека. Как войти в состояние потока в работе, хобби и отношениях.', 650.00, '978-5-04-099556-8', 480, 1, 17, 2, TRUE, FALSE, 11200, 7800, 4.93, 4870, '/books/flow_experience.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Игры, в которые играют люди', 'Эрик Берн о транзактном анализе и психологических играх, которые люди бессознательно разыгрывают в отношениях. Как распознавать манипуляции и выходить из игр.', 550.00, '978-5-04-092567-9', 384, 1, 17, 2, TRUE, FALSE, 12300, 8900, 4.91, 5230, '/books/games_people_play.jpg');

INSERT INTO books(title, annotation, price, isbn, page_count, binding_id, cat_id, pub_id, is_bestseller, is_new, views_count, sales_count, mean_rating, reviews_count, picture_url)
    VALUES ('Терапия беспокойства', 'Дэвид Бернс о когнитивно-поведенческой терапии для лечения тревожности. Практические техники преодоления страхов, панических атак и постоянного беспокойства.', 599.00, '978-5-04-099278-8', 432, 1, 17, 2, FALSE, FALSE, 7800, 4900, 4.87, 3450, '/books/anxiety_therapy.jpg');

-- ========================================================
-- ПРИВЯЗКА НОВЫХ КНИГ К АВТОРАМ
-- ========================================================
INSERT INTO book_authors(book_id, author_id)
    VALUES (81, 47);

INSERT INTO book_authors(book_id, author_id)
    VALUES (82, 49);

INSERT INTO book_authors(book_id, author_id)
    VALUES (83, 46);

INSERT INTO book_authors(book_id, author_id)
    VALUES (84, 50);

INSERT INTO book_authors(book_id, author_id)
    VALUES (85, 3);

INSERT INTO book_authors(book_id, author_id)
    VALUES (86, 51);

INSERT INTO book_authors(book_id, author_id)
    VALUES (87, 52);

INSERT INTO book_authors(book_id, author_id)
    VALUES (88, 53);

INSERT INTO book_authors(book_id, author_id)
    VALUES (89, 54);

INSERT INTO book_authors(book_id, author_id)
    VALUES (90, 55);

INSERT INTO book_authors(book_id, author_id)
    VALUES (91, 56);

INSERT INTO book_authors(book_id, author_id)
    VALUES (92, 57);

INSERT INTO book_authors(book_id, author_id)
    VALUES (93, 58);

INSERT INTO book_authors(book_id, author_id)
    VALUES (94, 59);

INSERT INTO book_authors(book_id, author_id)
    VALUES (95, 60);

INSERT INTO book_authors(book_id, author_id)
    VALUES (96, 61);

INSERT INTO book_authors(book_id, author_id)
    VALUES (97, 62);

INSERT INTO book_authors(book_id, author_id)
    VALUES (98, 63);

INSERT INTO book_authors(book_id, author_id)
    VALUES (99, 64);

INSERT INTO book_authors(book_id, author_id)
    VALUES (100, 65);

INSERT INTO book_authors(book_id, author_id)
    VALUES (101, 66);

INSERT INTO book_authors(book_id, author_id)
    VALUES (102, 67);

INSERT INTO book_authors(book_id, author_id)
    VALUES (103, 68);

INSERT INTO book_authors(book_id, author_id)
    VALUES (104, 69);

INSERT INTO book_authors(book_id, author_id)
    VALUES (105, 70);

INSERT INTO book_authors(book_id, author_id)
    VALUES (106, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (107, 19);

INSERT INTO book_authors(book_id, author_id)
    VALUES (108, 18);

INSERT INTO book_authors(book_id, author_id)
    VALUES (109, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (110, 20);

INSERT INTO book_authors(book_id, author_id)
    VALUES (111, 16);

INSERT INTO book_authors(book_id, author_id)
    VALUES (112, 19);

INSERT INTO book_authors(book_id, author_id)
    VALUES (113, 18);

INSERT INTO book_authors(book_id, author_id)
    VALUES (114, 17);

INSERT INTO book_authors(book_id, author_id)
    VALUES (115, 20);

INSERT INTO book_authors(book_id, author_id)
    VALUES (116, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (117, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (118, 33);

INSERT INTO book_authors(book_id, author_id)
    VALUES (119, 33);

INSERT INTO book_authors(book_id, author_id)
    VALUES (120, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (121, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (122, 33);

INSERT INTO book_authors(book_id, author_id)
    VALUES (123, 33);

INSERT INTO book_authors(book_id, author_id)
    VALUES (124, 24);

INSERT INTO book_authors(book_id, author_id)
    VALUES (125, 33);

-- ========================================================
-- ПРИВЯЗКА ТЕМ К НОВЫМ КНИГАМ
-- ========================================================
-- Книги русская классика (81-85)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (81, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (81, 48);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (82, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (82, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (83, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (83, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (84, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (84, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (85, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (85, 21);

-- Книги зарубежная классика (86-90)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (86, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (86, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (87, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (87, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (88, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (88, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (89, 40);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (89, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (90, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (90, 38);

-- Книги современная проза (91-95)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (91, 48);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (91, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (92, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (92, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (93, 47);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (93, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (94, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (94, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (95, 17);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (95, 40);

-- Книги фантастика и фэнтези (96-105)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (96, 50);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (96, 37);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (97, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (97, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (98, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (98, 41);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (99, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (99, 34);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (100, 36);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (100, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (101, 48);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (101, 42);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (102, 9);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (102, 45);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (103, 49);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (103, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (104, 49);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (104, 39);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (105, 33);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (105, 17);

-- Книги детективы (106-110)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (106, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (106, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (107, 39);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (107, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (108, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (108, 39);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (109, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (109, 49);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (110, 38);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (110, 21);

-- Книги деловая литература (111-115)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (111, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (111, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (112, 30);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (112, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (113, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (113, 31);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (114, 32);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (114, 29);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (115, 30);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (115, 1);

-- Книги маркетинг (116-120)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (116, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (116, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (117, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (117, 26);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (118, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (118, 30);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (119, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (119, 21);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (120, 25);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (120, 26);

-- Книги финансы (121-125)
INSERT INTO book_topics(book_id, topic_id)
    VALUES (121, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (121, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (122, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (122, 22);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (123, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (123, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (124, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (124, 1);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (125, 27);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (125, 28);

INSERT INTO book_topics(book_id, topic_id)
    VALUES (125, 29);

-- ========================================================
-- ОБНОВЛЕНИЕ ТРИГГЕРОВ (пересчёт путей категорий и рейтингов)
-- ========================================================
-- Пути категорий пересчитаются автоматически при вставке
-- Рейтинги книг установлены вручную для некоторых книг
UPDATE
    books
SET
    mean_rating = 4.85,
    reviews_count = 1250
WHERE
    id = 81;

UPDATE
    books
SET
    mean_rating = 4.79,
    reviews_count = 980
WHERE
    id = 82;

UPDATE
    books
SET
    mean_rating = 4.82,
    reviews_count = 1100
WHERE
    id = 83;

UPDATE
    books
SET
    mean_rating = 4.75,
    reviews_count = 870
WHERE
    id = 84;

UPDATE
    books
SET
    mean_rating = 4.88,
    reviews_count = 1450
WHERE
    id = 85;

UPDATE
    books
SET
    mean_rating = 4.92,
    reviews_count = 2100
WHERE
    id = 86;

UPDATE
    books
SET
    mean_rating = 4.87,
    reviews_count = 1870
WHERE
    id = 87;

UPDATE
    books
SET
    mean_rating = 4.95,
    reviews_count = 3200
WHERE
    id = 88;

UPDATE
    books
SET
    mean_rating = 4.83,
    reviews_count = 1340
WHERE
    id = 89;

UPDATE
    books
SET
    mean_rating = 4.90,
    reviews_count = 1980
WHERE
    id = 90;

UPDATE
    books
SET
    mean_rating = 4.86,
    reviews_count = 1560
WHERE
    id = 96;

UPDATE
    books
SET
    mean_rating = 4.89,
    reviews_count = 1780
WHERE
    id = 100;

UPDATE
    books
SET
    mean_rating = 4.93,
    reviews_count = 2340
WHERE
    id = 106;

UPDATE
    books
SET
    mean_rating = 4.91,
    reviews_count = 2100
WHERE
    id = 111;

UPDATE
    books
SET
    mean_rating = 4.94,
    reviews_count = 2560
WHERE
    id = 121;

