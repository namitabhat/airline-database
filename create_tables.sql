DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS reservation_passenger;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS weeklyschedule;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS airport;
DROP TABLE IF EXISTS dayfactor;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS profitfactor;
DROP TABLE IF EXISTS passenger;


DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addRoute;

DROP FUNCTION IF EXISTS calculatePrice;
DROP FUNCTION IF EXISTS calculateFreeSeats;


DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;


DROP VIEW IF EXISTS allFlights;



/*Question 2*/

CREATE TABLE passenger (
    pid INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    passport_no VARCHAR(40) UNIQUE,
    name VARCHAR(30),
    CONSTRAINT passport_no_unique UNIQUE (passport_no)
);

CREATE TABLE contact (
    contact_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY ,
    name VARCHAR(30),
    pid INTEGER,
    passport_no INTEGER,
    email VARCHAR(30),
    phone BIGINT,
    FOREIGN KEY (pid) REFERENCES `passenger`(pid)
);

CREATE TABLE profitfactor (
    year INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    factor DOUBLE
);

CREATE TABLE dayfactor (
    year INTEGER,
    day VARCHAR(10) NOT NULL,
    factor DOUBLE,
    FOREIGN KEY (year) REFERENCES profitfactor(year),
    PRIMARY KEY (day, year)
);

CREATE TABLE airport (
    airport_code VARCHAR(3) NOT NULL PRIMARY KEY,
    airport_name VARCHAR(30),
    country VARCHAR(30)
);

CREATE TABLE route (
    route_price DOUBLE,
    year INTEGER,
    d_code VARCHAR(3),
    a_code VARCHAR(3),
    FOREIGN KEY (year) REFERENCES profitfactor(year),
    FOREIGN KEY (d_code) REFERENCES airport(airport_code),
    FOREIGN KEY (a_code) REFERENCES airport(airport_code),
    PRIMARY KEY (year, d_code, a_code)
);

CREATE TABLE weeklyschedule (
    schedule_id INTEGER AUTO_INCREMENT,
    departure_time TIME,
    year INTEGER,
    day VARCHAR(10),
    d_code VARCHAR(3),
    a_code VARCHAR(3),

    FOREIGN KEY (day) REFERENCES dayfactor(day),
    FOREIGN KEY (year) REFERENCES dayfactor(year),
    FOREIGN KEY (d_code) REFERENCES route(d_code),
    FOREIGN KEY (a_code) REFERENCES route(a_code),
    PRIMARY KEY (schedule_id)

);


CREATE TABLE flight (
    flight_no INTEGER NOT NULL AUTO_INCREMENT,
    week_no INTEGER,
    total_seats INTEGER DEFAULT 40,
    schedule_id INTEGER,
    FOREIGN KEY (schedule_id) REFERENCES weeklyschedule(schedule_id),
    PRIMARY KEY (flight_no)
);



CREATE TABLE reservation (
    reservation_no INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    final_price DOUBLE,
    no_of_ppl INTEGER,
    flight_no INTEGER,
    contact_id INTEGER,
    FOREIGN KEY (contact_id) REFERENCES contact(contact_id),
    FOREIGN KEY (flight_no) REFERENCES flight(flight_no)
);

CREATE TABLE reservation_passenger (
    reservation_no INTEGER,
    pid INTEGER,
    FOREIGN KEY (pid) REFERENCES passenger(pid),
    FOREIGN KEY (reservation_no) REFERENCES reservation(reservation_no),
    PRIMARY KEY (reservation_no, pid)
);

CREATE TABLE booking (
    ticket_no INTEGER NOT NULL PRIMARY KEY,
    seat_price DOUBLE,
    reservation_no INTEGER,
    pid INTEGER,
    FOREIGN KEY (pid) REFERENCES passenger(pid),
    FOREIGN KEY (reservation_no) REFERENCES reservation(reservation_no)
);


CREATE TABLE payment (
    payment_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    creditcard_no BIGINT,
    creditcard_name varchar(30),
    reservation_no INTEGER,
    FOREIGN KEY (reservation_no) REFERENCES reservation(reservation_no)
);














