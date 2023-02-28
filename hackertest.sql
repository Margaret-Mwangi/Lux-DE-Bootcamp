WITH submissions_grpd AS
(
    SELECT submission_date, hacker_id, COUNT(1) AS tot_count 
    FROM Submissions 
    GROUP BY submission_date, hacker_id
),
unique_hackers AS
(
    SELECT submission_date, COUNT(hacker_id) AS no_of_hackers FROM
    (
        SELECT submission_date, hacker_id, 
        ROW_NUMBER() OVER (PARTITION BY hacker_id ORDER BY submission_date) AS hacker_row_Num,
        DENSE_RANK() OVER (ORDER BY submission_date) AS Date_rank
        FROM submissions_grpd
    ) B
    WHERE hacker_row_Num = Date_rank
    GROUP BY submission_date
)
SELECT uniq.submission_date, uniq.no_of_hackers, hack.hacker_id, Hackers.name
FROM unique_hackers uniq
INNER JOIN
(
    SELECT submission_date, hacker_id, tot_count max_count FROM 
    (
        SELECT *, 
        ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY tot_count DESC, hacker_id) Row_num
        FROM submissions_grpd
    ) A
    WHERE Row_num = 1
) hack
ON
hack.submission_date = uniq.submission_date
INNER JOIN
Hackers
ON
hack.hacker_id = Hackers.hacker_id