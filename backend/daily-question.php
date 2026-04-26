<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

$userId = $_GET['user_id'] ?? null;

try {
    $db = getDB();
    
    // Get today's daily question
    $stmt = $db->prepare("
        SELECT id, question, correct_answer, explanation, category, is_daily, date, true_votes, false_votes
        FROM questions
        WHERE is_daily = 1 AND date = CURDATE()
        LIMIT 1
    ");
    $stmt->execute();
    $question = $stmt->fetch();
    
    if (!$question) {
        sendError('لا يوجد سؤال اليوم');
    }
    
    // Check if user already answered
    if ($userId) {
        $stmt = $db->prepare("
            SELECT answer, is_correct
            FROM answers
            WHERE user_id = ? AND question_id = ? AND DATE(created_at) = CURDATE()
            LIMIT 1
        ");
        $stmt->execute([$userId, $question['id']]);
        $answer = $stmt->fetch();
        
        if ($answer) {
            $question['user_answer'] = (bool)$answer['answer'];
            $question['is_correct'] = (bool)$answer['is_correct'];
        }
    }
    
    sendSuccess($question);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب السؤال: ' . $e->getMessage());
}
?>
