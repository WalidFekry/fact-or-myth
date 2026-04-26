<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    sendError('معرف المستخدم مطلوب');
}

try {
    $db = getDB();
    
    // Get user info
    $stmt = $db->prepare("SELECT id, name, avatar FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    if (!$user) {
        sendError('المستخدم غير موجود');
    }
    
    // Get stats
    $stmt = $db->prepare("
        SELECT 
            COUNT(*) as total_answers,
            SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
            SUM(CASE WHEN is_correct = 0 THEN 1 ELSE 0 END) as wrong_answers
        FROM answers
        WHERE user_id = ?
    ");
    $stmt->execute([$userId]);
    $stats = $stmt->fetch();
    
    // Get streak
    $stmt = $db->prepare("SELECT current_streak FROM streaks WHERE user_id = ?");
    $stmt->execute([$userId]);
    $streak = $stmt->fetch();
    
    // Calculate accuracy
    $accuracy = 0;
    if ($stats['total_answers'] > 0) {
        $accuracy = round(($stats['correct_answers'] * 100.0) / $stats['total_answers'], 2);
    }
    
    $profile = [
        'user_id' => $user['id'],
        'name' => $user['name'],
        'avatar' => $user['avatar'],
        'total_answers' => (int)$stats['total_answers'],
        'correct_answers' => (int)$stats['correct_answers'],
        'wrong_answers' => (int)$stats['wrong_answers'],
        'accuracy' => $accuracy,
        'current_streak' => $streak ? (int)$streak['current_streak'] : 0
    ];
    
    sendSuccess($profile);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب الملف الشخصي: ' . $e->getMessage());
}
?>
