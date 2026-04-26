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
    
    // Get user stats (include users with at least 1 answer)
    $stmt = $db->prepare("
        SELECT 
            u.id as user_id,
            u.name as user_name,
            u.avatar as user_avatar,
            SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_count,
            SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_count,
            COUNT(*) as total_answers,
            ROUND(
                (SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
                2
            ) as percentage
        FROM users u
        INNER JOIN answers a ON u.id = a.user_id
        INNER JOIN questions q ON a.question_id = q.id
        WHERE u.id = ? AND q.is_daily = 1
        GROUP BY u.id
        HAVING COUNT(*) >= 1
    ");
    $stmt->execute([$userId]);
    $userStats = $stmt->fetch();
    
    // If user has no answers, return default data
    if (!$userStats) {
        // Get user info
        $stmt = $db->prepare("SELECT id, name, avatar FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if (!$user) {
            sendError('المستخدم غير موجود');
        }
        
        sendSuccess([
            'user_id' => (int)$user['id'],
            'user_name' => $user['name'],
            'user_avatar' => $user['avatar'],
            'correct_count' => 0,
            'wrong_count' => 0,
            'total_answers' => 0,
            'percentage' => 0.0,
            'rank' => null,
            'eligible' => false
        ]);
        return;
    }
    
    // Add eligibility flag
    $totalAnswers = (int)$userStats['total_answers'];
    $userStats['eligible'] = $totalAnswers >= 5;
    
    // Calculate rank (only among users with at least 1 answer)
    $stmt = $db->prepare("
        SELECT COUNT(*) + 1 as rank
        FROM (
            SELECT 
                u.id,
                SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_count,
                ROUND(
                    (SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
                    2
                ) as percentage
            FROM users u
            INNER JOIN answers a ON u.id = a.user_id
            INNER JOIN questions q ON a.question_id = q.id
            WHERE q.is_daily = 1
            GROUP BY u.id
            HAVING COUNT(*) >= 1
        ) as rankings
        WHERE 
            percentage > ? OR 
            (percentage = ? AND correct_count > ?)
    ");
    $stmt->execute([
        $userStats['percentage'],
        $userStats['percentage'],
        $userStats['correct_count']
    ]);
    $rankData = $stmt->fetch();
    
    $userStats['rank'] = (int)$rankData['rank'];
    $userStats['total_answers'] = $totalAnswers;
    
    sendSuccess($userStats);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب الترتيب: ' . $e->getMessage());
}
?>
