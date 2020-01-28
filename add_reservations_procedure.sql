DELIMITER //

CREATE PROCEDURE addReservation (
  IN departure_airport_code VARCHAR(3),
  IN arrival_airport_code VARCHAR(3),
  IN ryear INTEGER,
  IN rweek INTEGER,
  IN rday VARCHAR(10),
  IN dep_time TIME,
  IN number_of_passengers INTEGER,
  OUT output_reservation_nr INTEGER
)
 BEGIN

 SET @sched_id = (SELECT schedule_id FROM weeklyschedule
  WHERE d_code=departure_airport_code AND a_code=arrival_airport_code
   AND year=ryear AND day=rday AND departure_time=dep_time);

   IF (@sched_id IS NULL) THEN
   SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
     MESSAGE_TEXT = 'There exist no flight for the given route, date and time';
   END IF;

 SET @fno=(SELECT flight_no FROM flight WHERE week_no=rweek AND schedule_id=@sched_id );

 IF (@fno IS NULL) THEN
 SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
   MESSAGE_TEXT = 'There exist no flight for the given route, date and time';
END IF;

SET @freeseats = calculateFreeSeats(@fno);
  IF @freeseats >= number_of_passengers THEN

  INSERT INTO reservation(no_of_ppl, final_price, flight_no) VALUES (number_of_passengers, calculatePrice(@fno)*number_of_passengers, @fno);
  SELECT LAST_INSERT_ID() INTO output_reservation_nr;

  ELSE
  SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
    MESSAGE_TEXT = 'There are not enough seats available on the chosen flight';


  END IF;
 END;

//
DELIMITER ;



DELIMITER //

CREATE PROCEDURE addContact(
  reservation_nr INTEGER,
  passport_number VARCHAR(40),
  cemail VARCHAR(30),
  cphone BIGINT)
 BEGIN

 SET @rno = (SELECT reservation_no FROM reservation WHERE reservation_no=reservation_nr);
 IF (@rno IS NULL) THEN
 SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
   MESSAGE_TEXT = 'The given reservation number does not exist';
END IF;

SET @pid = (SELECT pid FROM passenger WHERE passport_no=passport_number);
SET @prid = (SELECT pid FROM reservation_passenger WHERE reservation_no=reservation_nr AND pid=@pid);

IF (@prid IS NULL) THEN
SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
  MESSAGE_TEXT = 'The person is not a passenger of the reservation';
END IF;

  INSERT INTO contact(email, phone, passport_no) VALUES (cemail, cphone, passport_number);
  SET @cid = LAST_INSERT_ID();

  UPDATE reservation set contact_id=LAST_INSERT_ID() WHERE reservation_no=@rno;
 END;

//
DELIMITER ;




DELIMITER //

CREATE PROCEDURE addPassenger(
  IN reservation_nr INTEGER,
  IN passport_number varchar(40),
  IN name varchar(30))
 BEGIN
  SET @rno = (SELECT reservation_no FROM reservation WHERE reservation_no=reservation_nr);
  IF (@rno IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
    MESSAGE_TEXT = 'The given reservation number does not exist';
 END IF;

 SET @pno = (SELECT payment_id FROM payment WHERE reservation_no=reservation_nr);
 IF (@pno IS NOT NULL) THEN
 SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
   MESSAGE_TEXT = 'The booking has already been payed and no futher passengers can be added';
END IF;

  INSERT IGNORE INTO passenger(passport_no, name) VALUES (passport_number, name);
  SET @pid = (SELECT pid FROM passenger WHERE passport_no=passport_number);
  INSERT INTO reservation_passenger(reservation_no, pid) VALUES (@rno, @pid);
 END;

//
DELIMITER ;



DELIMITER //

CREATE PROCEDURE addPayment (
  IN reservation_nr INTEGER,
  IN cardholder_name varchar(30),
  IN credit_card_number BIGINT
)
 BEGIN

 SET @rno = (SELECT reservation_no FROM reservation WHERE reservation_no=reservation_nr);
 IF (@rno IS NULL) THEN
 SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
   MESSAGE_TEXT = 'The given reservation number does not exist';
 END IF;


 SET @cno = (SELECT contact_id FROM reservation WHERE reservation_no=reservation_nr);
 IF (@cno IS NULL) THEN
 SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001,
   MESSAGE_TEXT = 'The reservation has no contact yet';
END IF;

SET @fno = (SELECT flight_no FROM reservation WHERE reservation_no=@rno);

SET @freeseats = calculateFreeSeats(@fno);
SET @nops = (SELECT COUNT(pid) FROM reservation_passenger WHERE reservation_no=@rno);
SELECT sleep(5);
  IF @freeseats >= @nops THEN
    INSERT INTO payment(creditcard_no, creditcard_name, reservation_no) VALUES (credit_card_number, creditcard_name, @rno);


  ELSE
  SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 3001,
    MESSAGE_TEXT = 'There are not enough seats available on the flight anymore, deleting reservation';

  END IF;
 END;

//
DELIMITER ;