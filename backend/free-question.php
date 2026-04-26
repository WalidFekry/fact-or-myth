<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

$category = $_GET['category'] ?? 'عشوائي';

try {
    $db = getDB();
    
    // Build query based on category
    if ($category === 'عشوائي') {
        $stmt = $db->prepare("
            SELECT id, question, correct_answer, explanation, category, is_daily
            FROM questions
            WHERE is_daily = 0
            ORDER BY RAND()
            LIMIT 1
        ");
        $stmt->execute();
    } else {
        $stmt = $db->prepare("
            SELECT id, question, correct_answer, explanation, category, is_daily
            FROM questions
            WHERE is_daily = 0 AND category = ?
            ORDER BY RAND()
            LIMIT 1
        ");
        $stmt->execute([$category]);
    }
    
    $question = $stmt->fetch();
    
    if (!$question) {
        sendError('لا توجد أسئلة في هذه الفئة');
    }
    
    sendSuccess($question);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب السؤال: ' . $e->getMessage());
}
?>
