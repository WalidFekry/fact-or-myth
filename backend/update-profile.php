<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

$input = getJsonInput();
$userId = $input['user_id'] ?? null;
$name = trim($input['name'] ?? '');
$avatar = trim($input['avatar'] ?? '');

// Validation
if (!$userId) {
    sendError('معرف المستخدم مطلوب');
}

if (empty($name)) {
    sendError('الاسم مطلوب');
}

if (empty($avatar)) {
    sendError('الصورة مطلوبة');
}

try {
    $db = getDB();
    
    // Update user
    $stmt = $db->prepare("UPDATE users SET name = ?, avatar = ? WHERE id = ?");
    $stmt->execute([$name, $avatar, $userId]);
    
    // Get updated profile
    $stmt = $db->prepare("
        SELECT 
            u.id as user_id,
            u.name,
            u.avatar,
            COUNT(a.id) as total_answers,
            SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
            SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_answers,
            COALESCE(s.current_streak, 0) as current_streak
        FROM users u
        LEFT JOIN answers a ON u.id = a.user_id
        LEFT JOIN streaks s ON u.id = s.user_id
        WHERE u.id = ?
        GROUP BY u.id
    ");
    $stmt->execute([$userId]);
    $profile = $stmt->fetch();
    
    // Calculate accuracy
    $accuracy = 0;
    if ($profile['total_answers'] > 0) {
        $accuracy = round(($profile['correct_answers'] * 100.0) / $profile['total_answers'], 2);
    }
    
    $profile['accuracy'] = $accuracy;
    $profile['total_answers'] = (int)$profile['total_answers'];
    $profile['correct_answers'] = (int)$profile['correct_answers'];
    $profile['wrong_answers'] = (int)$profile['wrong_answers'];
    $profile['current_streak'] = (int)$profile['current_streak'];
    
    sendSuccess($profile, 'تم تحديث الملف الشخصي');
    
} catch (PDOException $e) {
    sendError('خطأ في تحديث الملف الشخصي: ' . $e->getMessage());
}
?>
