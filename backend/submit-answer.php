<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

$input = getJsonInput();
$userId = $input['user_id'] ?? null;
$questionId = $input['question_id'] ?? null;
$answer = $input['answer'] ?? null;

// Validation
if (!isset($questionId)) {
    sendError('معرف السؤال مطلوب');
}

if (!array_key_exists('answer', $input)) {
    sendError('الإجابة مطلوبة');
}

try {
    $db = getDB();
    
    // Get question
    $stmt = $db->prepare("SELECT correct_answer, is_daily FROM questions WHERE id = ?");
    $stmt->execute([$questionId]);
    $question = $stmt->fetch();
    
    if (!$question) {
        sendError('السؤال غير موجود');
    }
    
    $isCorrect = ((bool)$answer === (bool)$question['correct_answer']) ? 1 : 0;
    
    // Check if already answered (for daily questions with logged-in users)
    if ($userId && $question['is_daily']) {
        $stmt = $db->prepare("
            SELECT id FROM answers
            WHERE user_id = ? AND question_id = ? AND DATE(created_at) = CURDATE()
        ");
        $stmt->execute([$userId, $questionId]);
        if ($stmt->fetch()) {
            // Return 409 Conflict for already answered
            http_response_code(409);
            sendError('لقد أجبت على هذا السؤال اليوم');
        }
    }
    
    // Insert answer
    $stmt = $db->prepare("
        INSERT INTO answers (user_id, question_id, answer, is_correct)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $questionId, $answer, $isCorrect]);
    
    // Update voting statistics in questions table
    if ($answer) {
        $stmt = $db->prepare("UPDATE questions SET true_votes = true_votes + 1 WHERE id = ?");
    } else {
        $stmt = $db->prepare("UPDATE questions SET false_votes = false_votes + 1 WHERE id = ?");
    }
    $stmt->execute([$questionId]);
    
    // Get updated vote counts
    $stmt = $db->prepare("SELECT true_votes, false_votes FROM questions WHERE id = ?");
    $stmt->execute([$questionId]);
    $votes = $stmt->fetch();
    
    // Update streak (only for daily questions with logged-in users)
    if ($userId && $question['is_daily']) {
        $stmt = $db->prepare("SELECT current_streak, last_answer_date FROM streaks WHERE user_id = ?");
        $stmt->execute([$userId]);
        $streak = $stmt->fetch();
        
        $newStreak = 1;
        if ($streak) {
            $lastDate = $streak['last_answer_date'];
            $yesterday = date('Y-m-d', strtotime('-1 day'));
            
            if ($lastDate === $yesterday) {
                $newStreak = $streak['current_streak'] + 1;
            }
        }
        
        $stmt = $db->prepare("
            INSERT INTO streaks (user_id, current_streak, last_answer_date)
            VALUES (?, ?, CURDATE())
            ON DUPLICATE KEY UPDATE
            current_streak = ?,
            last_answer_date = CURDATE()
        ");
        $stmt->execute([$userId, $newStreak, $newStreak]);
    }
    
    sendSuccess([
        'is_correct' => (bool)$isCorrect,  // Ensure boolean type
        'correct_answer' => (bool)$question['correct_answer'],
        'true_votes' => (int)$votes['true_votes'],
        'false_votes' => (int)$votes['false_votes']
    ]);
    
} catch (PDOException $e) {
    sendError('خطأ في حفظ الإجابة: ' . $e->getMessage());
}
?>
