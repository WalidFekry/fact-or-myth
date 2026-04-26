<?php
require_once 'config.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Method not allowed', 405);
}

// Get JSON input
$input = getJsonInput();
$userId = $input['user_id'] ?? null;

// Validate input
if (!$userId) {
    sendError('معرف المستخدم مطلوب');
}

try {
    $pdo = getDB();
    
    // Start transaction
    $pdo->beginTransaction();
    
    // Delete user's answers
    $stmt = $pdo->prepare("DELETE FROM answers WHERE user_id = ?");
    $stmt->execute([$userId]);
    
    // Delete user's comments
    $stmt = $pdo->prepare("DELETE FROM comments WHERE user_id = ?");
    $stmt->execute([$userId]);
    
    // Delete user account
    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    
    // Check if user was deleted
    if ($stmt->rowCount() === 0) {
        $pdo->rollBack();
        sendError('المستخدم غير موجود', 404);
    }
    
    // Commit transaction
    $pdo->commit();
    
    sendSuccess(null, 'تم حذف الحساب بنجاح');
    
} catch (PDOException $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    sendError('حدث خطأ أثناء حذف الحساب: ' . $e->getMessage(), 500);
}
?>
