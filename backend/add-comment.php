<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

$input = getJsonInput();
$userId = $input['user_id'] ?? null;
$questionId = $input['question_id'] ?? null;
$comment = trim($input['comment'] ?? '');

// Validation
if (!$userId) {
    sendError('معرف المستخدم مطلوب');
}

if (!$questionId) {
    sendError('معرف السؤال مطلوب');
}

if (empty($comment)) {
    sendError('التعليق مطلوب');
}

try {
    $db = getDB();
    
    // Check if user already commented on this question
    $stmt = $db->prepare("
        SELECT COUNT(*) as count FROM comments
        WHERE user_id = ? AND question_id = ?
    ");
    $stmt->execute([$userId, $questionId]);
    $result = $stmt->fetch();
    
    if ($result['count'] > 0) {
        sendError('لقد قمت بإضافة تعليق بالفعل على هذا السؤال');
    }
    
    // Insert comment
    $stmt = $db->prepare("
        INSERT INTO comments (user_id, question_id, comment)
        VALUES (?, ?, ?)
    ");
    $stmt->execute([$userId, $questionId, $comment]);
    
    $commentId = $db->lastInsertId();
    
    // Get comment with user data
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
        WHERE c.id = ?
    ");
    $stmt->execute([$commentId]);
    $commentData = $stmt->fetch();
    
    sendSuccess($commentData, 'تم إضافة التعليق');
    
} catch (PDOException $e) {
    sendError('خطأ في إضافة التعليق: ' . $e->getMessage());
}
?>
