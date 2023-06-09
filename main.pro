implement main
    open core, stdio, file

domains
    genre = драма; боевик; ужасы.
    фильмы = фильмы(integer FilmId, string FilmName, string ReleaseYear, string Producer, genre Genre, real Rating).
    кинотеатры = кинотеатры(integer CinemaId, string CinemaName, string Adress, string PhoneNum, string SeatsNum).

class facts - kinoDb
    кинотеатр : (integer CinemaId, string CinemaName, string Adress, string PhoneNum, string SeatsNum).
    кинофильм : (integer FilmId, string FilmName, string ReleaseYear, string Producer, genre Genre, real Rating).
    показывают : (integer CinemaId, integer FilmId, string ShowDate, string ShowTime, integer Revenue).
    чек : (integer Total).
    стоимостьБилета : (integer FilmId, integer Price).

clauses
    кинотеатр(1, "Формула Кино Чертаново", "мкр. Северное Чертаново, 1а, стр. 2", "8 (800) 505-67-91", "1610 мест").
    кинотеатр(2, "Формула Кино на Полежаевской", "Москва, Хорошевское шоссе, д. 27", "8 (800) 700-01-11", "1840 мест").
    кинотеатр(3, "Формула Кино ЦДМ", "Москва, Театральный пр., 5/1", "8 (812) 363-36-78", "1840 мест").

    кинофильм(11, "Вызов", "2023", "Клим Шипенко", драма, 6.5).
    кинофильм(12, "Джон Уик 4", "2023", "Чад Стахелски", боевик, 8.2).
    кинофильм(13, "Возрожденные", "2023", "Егор Баранов", ужасы, 7.4).

    показывают(1, 11, "06.05.2023", "15:05", 15000).
    показывают(1, 12, "06.05.2023", "22:35", 18000).
    показывают(2, 11, "06.05.2023", "15:20", 14000).
    показывают(2, 12, "06.05.2023", "15:45", 24000).
    показывают(3, 11, "06.05.2023", "15:35", 20000).
    показывают(3, 12, "06.05.2023", "17:20", 22000).
    показывают(3, 13, "06.05.2023", "00:05", 12000).

    стоимостьБилета(11, 300).
    стоимостьБилета(12, 250).
    стоимостьБилета(13, 340).

    чек(0).

class predicates  %вспомогательные предикаты для рассчёта
    длина : (A*) -> integer.
    сумма : (real* List) -> real Sum.
    среднее : (real* List) -> real Average determ.

clauses
    длина([]) = 0.
    длина([_ | T]) = длина(T) + 1. % считаем длину

    сумма([]) = 0.
    сумма([H | T]) = сумма(T) + H. % считаем сумму

    среднее(L) = сумма(L) / длина(L) :-
        длина(L) > 0. % считаем среднее значение

class predicates
    вывестиКинотеатры : ().
    вывестиФильмы : ().
    /*данныеФильма : (string FilmId).*/
    вывестиПриветствие : ().
    кинотеатр3000 : ().
    купитьБилет : (integer FilmId).
    вывестиСумму : ().
    вывестиСтоимостьБилета : (integer FilmId).
    фильмыКинотеатраСписок : (integer CinemaId) -> string* Компоненты determ. %поиск фильмов по критерию
    колФильмов : (string FilmName) -> integer N determ.
    среднийРейтингФильмов : (integer FilmId) -> real Sum determ.
    найтиФильм : (string Фильм, string* L) determ.

clauses
    вывестиКинотеатры() :-
        Кинотеатры = [ кинотеатры(CinemaId, CinemaName, Adress, PhoneNum, SeatsNum) || кинотеатр(CinemaId, CinemaName, Adress, PhoneNum, SeatsNum) ],
        %write(CinemaId, " | ", CinemaName, " | ", Adress, " | ", PhoneNum, " | ", SeatsNum),
        foreach кинотеатры(CinemaId, CinemaName, Adress, PhoneNum, SeatsNum) = list::getMember_nd(Кинотеатры) do
            write(CinemaId, " | ", CinemaName, " | ", Adress, " | ", PhoneNum, " | ", SeatsNum),
            nl
        end foreach.

    фильмыКинотеатраСписок(CinemaId) = List :-
        кинотеатр(CinemaId, _, _, _, _),
        !,
        List =
            [ FilmName ||
                показывают(CinemaId, FilmId, _, _, _),
                кинофильм(FilmId, FilmName, _, _, _, _)
            ].

    колФильмов(X) = длина(фильмыКинотеатраСписок(toTerm(X))). % длина списка с фильмами

    среднийРейтингФильмов(CinemaId) = Average :-
        кинотеатр(CinemaId, _, _, _, _),
        !,
        Average =
            среднее(
                [ Rating ||
                    показывают(CinemaId, FilmId, _, _, _),
                    кинофильм(FilmId, _, _, _, _, Rating)
                ]).

    найтиФильм(Фильм, [_ | ОстальныеЭлементы]) :-
        % поиск по списку
        найтиФильм(Фильм, ОстальныеЭлементы).

    вывестиФильмы() :-
        Фильмы =
            [ фильмы(FilmId, FilmName, ReleaseYear, Producer, Genre, Rating) || кинофильм(FilmId, FilmName, ReleaseYear, Producer, Genre, Rating) ],
        %write("ID |      Name |    Year   |    Producer    |   Genre   |   Rating  "),
        foreach фильмы(FilmId, FilmName, ReleaseYear, Producer, Genre, Rating) = list::getMember_nd(Фильмы) do
            write(FilmId, " | ", FilmName, " | ", ReleaseYear, " | ", Producer, " | ", Genre, " | ", Rating),
            nl
        end foreach.

    купитьБилет(FilmId) :-
        стоимостьБилета(FilmId, Price),
        retract(чек(Total)),
        asserta(чек(Total + Price)),
        fail.
    купитьБилет(_) :-
        nl.

    вывестиСтоимостьБилета(FilmId) :-
        write("Стоимость билета: "),
        стоимостьБилета(FilmId, Price),
        write(Price),
        nl,
        fail.
    вывестиСтоимостьБилета(_) :-
        nl.

    вывестиСумму() :-
        чек(X),
        write(X),
        nl,
        fail.
    вывестиСумму() :-
        write("↑ Приложите карту: ↑").

    вывестиПриветствие() :-
        write("Добро пожаловать в Кинотеатр3000 - лучший помощник в нахождении кинотеатров и фильмов.").

    кинотеатр3000() :-
        write("\n"),
        write("--------------------------------------------------------------------------------------------------------------------\n"),
        write("Введите 1 - чтобы вывести работающие кинотеатры\n"),
        write("Введите 2 - чтобы вывести фильмы проката\n"),
        write("Введите 3 - чтобы купить билет\n"),
        write("Введите 4 - чтобы вывести фильмы желаемого кинотеатра\n"),
        write("Введите ~ - чтобы найти желаемый фильм\n"),
        write("Введите 5 - чтобы выйти из программы\n"),
        write("--------------------------------------------------------------------------------------------------------------------\n"),
        Num = stdio::readLine(),
        write("\n"),
        if Num = "1" then
            вывестиКинотеатры(),
            кинотеатр3000(),
            fail
        elseif Num = "2" then
            вывестиФильмы(),
            кинотеатр3000(),
            fail
        elseif Num = "3" then
            /*забронироватьМеста(),*/
            write("Введите ID фильма на который хотите пойти: "),
            ID = stdio::readLine(),
            if ID = "11" or ID = "12" or ID = "13" then
                вывестиСтоимостьБилета(toTerm(ID)),
                write("Оформить чек?\n"),
                write("1 - ДА\n"),
                write("2 - НЕТ\n"),
                nl,
                Number = stdio::readLine(),
                if Number = "1" then
                    купитьБилет(toTerm(ID)),
                    write("Сумма к оплате: "),
                    вывестиСумму(),
                    кинотеатр3000(),
                    fail
                elseif Number = "2" then
                    write("Возвращаюсь на главную"),
                    nl,
                    кинотеатр3000(),
                    fail
                else
                    write("Некорректный символ, попробуйте ещё раз!\n"),
                    кинотеатр3000(),
                    fail
                end if
            else
                write("Некорректный символ, попробуйте ещё раз!\n"),
                кинотеатр3000(),
                fail
            end if
        elseif Num = "4" then
            write("Введите Id кинотеатра: "),
            X = stdio::readLine(),
            nl,
            L = фильмыКинотеатраСписок(toTerm(X)),
            write(L),
            nl,
            write("Количество фильмов = "),
            write(колФильмов(X)),
            nl,
            write("Средний рейтинг фильмов = "),
            write(среднийРейтингФильмов(toTerm(X))),
            nl,
            кинотеатр3000(),
            fail
        elseif Num = "~" then
            write("Введите название фильма, который хотите найти: "),
            Y = stdio::readLine(),
            nl,
            найтиФильм(toTerm(Y), ["Вызов", "Джон Уик 4", "Возрожденные"]),
            nl,
            write("Такой фильм есть в списке"),
            nl,
            кинотеатр3000(),
            fail
            or
            write("Такого фильма нет в списке"),
            nl,
            кинотеатр3000(),
            fail
        elseif Num = "5" then
            write("Вы точно хотите выйти?\n"),
            write("1 - ДА\n"),
            write("2 - НЕТ\n"),
            QuitNum = stdio::readLine(),
            if QuitNum = "1" then
                write("Вышли"),
                fail
            elseif QuitNum = "2" then
                кинотеатр3000(),
                fail
            else
                write("Некорректный символ, попробуйте ещё раз!\n"),
                кинотеатр3000(),
                fail
            end if
        else
            write("Некорректный символ, попробуйте ещё раз!\n"),
            кинотеатр3000(),
            fail
        end if.
    кинотеатр3000() :-
        nl,
        succeed.

clauses
    run() :-
        /*consult("kinodb.txt", kinoDb),*/
        вывестиПриветствие(),
        кинотеатр3000(),
        nl,
        fail.
    run() :-
        succeed.

end implement main

goal
    console::runUtf8(main::run).
