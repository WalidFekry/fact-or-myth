<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

$userId = $_GET['user_id'] ?? null;

try {
    $db = getDB();
    
    // TASK 2: Validate user if provided
    if ($userId) {
        $stmt = $db->prepare("SELECT id FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        if (!$stmt->fetch()) {
            // User not found - force logout
            http_response_code(401);
            sendError('المستخدم غير موجود', 401, ['force_logout' => true]);
        }
    }
    
    // TASK 1: Implement daily question rotation system
    // Get total count of daily questions
    $stmt = $db->query("SELECT COUNT(*) as total FROM questions WHERE is_daily = 1");
    $totalQuestions = (int)$stmt->fetch()['total'];
    
    if ($totalQuestions === 0) {
        sendError('لا توجد أسئلة يومية');
    }
    
    // Calculate question index based on date
    // Start date: 2024-01-01 (you can change this)
    $startTimestamp = strtotime('2024-01-01');
    $currentTimestamp = time();
    $dayNumber = floor(($currentTimestamp - $startTimestamp) / 86400);
    $questionIndex = $dayNumber % $totalQuestions;
    
    // Get today's question using rotation index
    $stmt = $db->prepare("
        SELECT id, question, correct_answer, explanation, category, is_daily, date, true_votes, false_votes
        FROM questions
        WHERE is_daily = 1
        ORDER BY id ASC
        LIMIT 1 OFFSET ?
    ");
    $stmt->execute([$questionIndex]);
    $question = $stmt->fetch();
    
    if (!$question) {
        sendError('لا يوجد سؤال اليوم');
    }
    
    // Check if user already answered today
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
