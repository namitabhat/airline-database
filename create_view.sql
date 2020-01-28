CREATE VIEW allFlights AS
  SELECT dep.airport_name as departure_city_name,
    arr.airport_name as destination_city_name,
    ws.departure_time,
    ws.day as departure_day,
    f.week_no as departure_week,
    ws.year as departure_year,
    calculateFreeSeats(f.flight_no) as nr_of_free_seats,
    calculatePrice(f.flight_no) as current_price_per_seat
  FROM flight as f, weeklyschedule as ws, airport as dep, airport as arr
  WHERE ws.schedule_id=f.schedule_id AND dep.airport_code=ws.d_code AND arr.airport_code=ws.a_code;