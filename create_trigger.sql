DELIMITER //

CREATE TRIGGER tickets
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
  INSERT INTO booking (ticket_no, reservation_no, pid) SELECT FLOOR(100 + RAND() * (100000 - 100 +1)), reservation_no, pid FROM reservation_passenger AS rp WHERE rp.reservation_no = NEW.reservation_no;
END;

//
DELIMITER ;