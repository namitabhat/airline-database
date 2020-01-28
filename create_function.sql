DELIMITER //
CREATE FUNCTION calculateFreeSeats(flightnumber INTEGER) RETURNS INT
  BEGIN

    RETURN (SELECT

    (SELECT total_seats from flight WHERE flight_no=flightnumber) -

    (SELECT COUNT(pid) from reservation_passenger WHERE reservation_no IN
    (
      SELECT reservation_no FROM reservation WHERE flight_no=flightnumber
      INTERSECT
      SELECT reservation_no FROM payment
    ))
    );

  END //
DELIMITER ;



DELIMITER //
CREATE FUNCTION calculatePrice(flightnumber INTEGER) RETURNS DOUBLE
  BEGIN

  SET @cyear = (SELECT year FROM weeklyschedule WHERE schedule_id IN (SELECT schedule_id FROM flight WHERE flight_no=flightnumber));
  SET @cday = (SELECT day FROM weeklyschedule WHERE schedule_id IN (SELECT schedule_id FROM flight WHERE flight_no=flightnumber));
  SET @sched_id = (SELECT schedule_id FROM flight WHERE flight_no=flightnumber);


    RETURN (SELECT

    (SELECT route_price FROM route WHERE
      d_code IN (SELECT ws.d_code
      FROM weeklyschedule as ws
      WHERE ws.schedule_id=@sched_id )

      AND

      a_code IN (SELECT ws.a_code
      FROM weeklyschedule as ws
      WHERE ws.schedule_id=@sched_id)


      AND

      year=@cyear

    )

    *

    (SELECT factor
      FROM dayfactor as d
      WHERE d.year=@cyear AND d.day=@cday)


    *

    (SELECT factor
      FROM profitfactor as p
      WHERE p.year=@cyear)

    *

    (SELECT (COUNT(pid)+1)/40 from reservation_passenger WHERE reservation_no IN
    (
      SELECT reservation_no FROM reservation WHERE flight_no=flightnumber
      INTERSECT
      SELECT reservation_no FROM payment
    ))
    );

  END //
DELIMITER ;