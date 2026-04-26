<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

try {
    $db = getDB();
    
    // Get all free questions (not daily)
    $stmt = $db->prepare("
        SELECT id, question, correct_answer, explanation, category
        FROM questions
        ORDER BY category, id
    ");
    $stmt->execute();
    $questions = $stmt->fetchAll();
    
    // Group by category for stats
    $stats = [
        'total' => count($questions),
        'by_category' => []
    ];
    
    foreach ($questions as $question) {
        $category = $question['category'];
        if (!isset($stats['by_category'][$category])) {
            $stats['by_category'][$category] = 0;
        }
        $stats['by_category'][$category]++;
    }
    
    sendSuccess([
        'questions' => $questions,
        'stats' => $stats,
        'sync_time' => date('Y-m-d H:i:s')
    ]);
    
} catch (PDOException $e) {
    sendError('خطأ في جلب الأسئلة: ' . $e->getMessage());
}
?>
