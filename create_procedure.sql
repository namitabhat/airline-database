DELIMITER //

CREATE PROCEDURE addYear (
  IN year INTEGER,
  IN factor DOUBLE
)
 BEGIN
  INSERT INTO profitfactor(year, factor) VALUES (year, factor);
 END;

//
DELIMITER ;



DELIMITER //

CREATE PROCEDURE addDay (
  IN year INTEGER,
  IN day VARCHAR(10),
  IN factor DOUBLE
)
 BEGIN
  INSERT INTO dayfactor(year, day, factor) VALUES (year, day, factor);
 END;

//
DELIMITER ;




DELIMITER //

CREATE PROCEDURE addDestination (
  IN airport_code VARCHAR(3),
  IN airport_name VARCHAR(30),
  IN country VARCHAR(30)
)
 BEGIN
  INSERT INTO airport(airport_code, airport_name, country) VALUES (airport_code, airport_name, country);
 END;

//
DELIMITER ;



DELIMITER //

CREATE PROCEDURE addRoute (
  IN departure_airport_code VARCHAR(3),
  IN arrival_airport_code VARCHAR(3),
  IN year INTEGER,
  IN routeprice DOUBLE
)
 BEGIN
  INSERT INTO route(d_code, a_code, year, route_price) VALUES (departure_airport_code, arrival_airport_code, year, routeprice);
 END;

//
DELIMITER ;




DELIMITER //

CREATE PROCEDURE addFlight (
  IN departure_airport_code VARCHAR(3),
  IN arrival_airport_code VARCHAR(3),
  IN year INTEGER,
  IN day VARCHAR(10),
  IN departure_time TIME
)
 BEGIN
  INSERT INTO weeklyschedule(d_code, a_code, year, day, departure_time) VALUES (departure_airport_code, arrival_airport_code, year, day, departure_time);

  SET @sched_id = LAST_INSERT_ID();

  FOR i IN 1..52
  DO
  INSERT INTO flight(week_no, schedule_id) VALUES (i, @sched_id);
  END FOR;
 END;

//
DELIMITER ;