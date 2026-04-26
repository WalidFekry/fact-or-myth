<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

$questionId = $_GET['question_id'] ?? null;

if (!$questionId) {
    sendError('معرف السؤال مطلوب');
}

try {
    $db = getDB();
    
    $stmt = $db->prepare("
        SELECT 
            c.id,
            c.user_id,
            u.name as user_name,
            u.avatar as user_avatar,
            c.question_id,
            c.comment,
            c.created_at
        FROM comments c
        INNER JOIN users u ON c.user_id = u.id
        WHERE c.question_id = ?
        ORDER BY c.created_at DESC
    ");
    $stmt->execute([$questionId]);
    $comments = $stmt->fetchAll();
    
    sendSuccess($comments);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب التعليقات: ' . $e->getMessage());
}
?>
