<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

$input = getJsonInput();
$name = trim($input['name'] ?? '');
$avatar = trim($input['avatar'] ?? '');
$guestAnswer = $input['guest_answer'] ?? null; // Optional guest answer data

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
    
    // Migrate guest answer if provided
    if ($guestAnswer && isset($guestAnswer['question_id'], $guestAnswer['answer'], $guestAnswer['is_correct'])) {
        $questionId = (int)$guestAnswer['question_id'];
        $answer = (bool)$guestAnswer['answer'];
        $isCorrect = (bool)$guestAnswer['is_correct'];
        
        // Check if question exists and is today's question
        $stmt = $db->prepare("SELECT id, correct_answer FROM questions WHERE id = ? AND is_daily = 1 AND date = CURDATE()");
        $stmt->execute([$questionId]);
        $question = $stmt->fetch();
        
        if ($question) {
            // Insert answer
            $stmt = $db->prepare("INSERT INTO answers (user_id, question_id, answer, is_correct) VALUES (?, ?, ?, ?)");
            $stmt->execute([$userId, $questionId, $answer ? 1 : 0, $isCorrect ? 1 : 0]);
            
            // Update voting statistics
            if ($answer) {
                $stmt = $db->prepare("UPDATE questions SET true_votes = true_votes + 1 WHERE id = ?");
            } else {
                $stmt = $db->prepare("UPDATE questions SET false_votes = false_votes + 1 WHERE id = ?");
            }
            $stmt->execute([$questionId]);
            
            // Update streak if correct
            if ($isCorrect) {
                $stmt = $db->prepare("UPDATE streaks SET current_streak = 1, last_answer_date = CURDATE() WHERE user_id = ?");
                $stmt->execute([$userId]);
            }
        }
    }
    
    // Get user data
    $stmt = $db->prepare("SELECT id, name, avatar, created_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    sendSuccess($user, 'تم التسجيل بنجاح');
    
} catch (PDOException $e) {
    sendError('خطأ في التسجيل: ' . $e->getMessage());
}
?>
