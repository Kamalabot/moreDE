CREATE TABLE initial_data (
    thing TEXT, 
    start_date TEXT 
)

INSERT INTO initial_data(thing, start_date)
VALUES 
('a', '2022-07-01'),
('b', '2022-07-01'),
('c', '2022-07-01'),
('a', '2022-08-01'),
('a', '2022-08-01'),
('d', '2022-08-01'),
('a', '2022-09-01'),
('e', '2022-09-01')
;

WITH ranking AS (
    SELECT 
        thing, 
        start_date, 
        DENSE_RANK() OVER (PARTITION BY thing ORDER BY start_date) AS ranked 
    FROM initial_data
), 
ranking_filtered AS (
    SELECT * FROM ranking
    WHERE ranked = 1
)
SELECT
    thing, 
    start_date, 
    sum(ranked) OVER (ORDER BY start_date) AS roller
FROM ranking_filtered
; 
