<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

try {
    $db = getDB();
    
    // Get leaderboard (only users with 1+ answers on daily questions)
    $stmt = $db->prepare("
        SELECT 
            u.id as user_id,
            u.name as user_name,
            u.avatar as user_avatar,
            SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_count,
            SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_count,
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
        ORDER BY percentage DESC, correct_count DESC
        LIMIT 100
    ");
    $stmt->execute();
    $leaderboard = $stmt->fetchAll();
    
    // Add rank
    $rank = 1;
    foreach ($leaderboard as &$item) {
        $item['rank'] = $rank++;
    }
    
    sendSuccess($leaderboard);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب الترتيب: ' . $e->getMessage());
}
?>
