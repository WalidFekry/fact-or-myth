-- Add voting statistics to questions table
ALTER TABLE questions 
ADD COLUMN true_votes INT DEFAULT 0 AFTER explanation,
ADD COLUMN false_votes INT DEFAULT 0 AFTER true_votes;

-- Update existing questions with current vote counts from answers table
UPDATE questions q
SET 
    true_votes = (
        SELECT COUNT(*) 
        FROM answers a 
        WHERE a.question_id = q.id AND a.answer = TRUE
    ),
    false_votes = (
        SELECT COUNT(*) 
        FROM answers a 
        WHERE a.question_id = q.id AND a.answer = FALSE
    );
