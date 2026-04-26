<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

$input = getJsonInput();
$name = trim($input['name'] ?? '');
$avatar = trim($input['avatar'] ?? '');

// Validation
if (empty($name)) {
    sendError('الاسم مطلوب');
}

if (empty($avatar)) {
    sendError('الصورة مطلوبة');
}

try {
    $db = getDB();
    
    // Insert user
    $stmt = $db->prepare("INSERT INTO users (name, avatar) VALUES (?, ?)");
    $stmt->execute([$name, $avatar]);
    
    $userId = $db->lastInsertId();
    
    // Initialize streak
    $stmt = $db->prepare("INSERT INTO streaks (user_id, current_streak) VALUES (?, 0)");
    $stmt->execute([$userId]);
    
    // Get user data
    $stmt = $db->prepare("SELECT id, name, avatar, created_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    sendSuccess($user, 'تم التسجيل بنجاح');
    
} catch (PDOException $e) {
    sendError('خطأ في التسجيل: ' . $e->getMessage());
}
?>
