<?php
require_once 'includes/auth.php';
require_once 'includes/db.php';

requireLogin();

$pageTitle = 'الرئيسية';
$pdo = getDB();

// Get statistics
$stats = [];

// Total users
$stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
$stats['users'] = $stmt->fetch()['count'];

// Total questions
$stmt = $pdo->query("SELECT COUNT(*) as count FROM questions");
$stats['questions'] = $stmt->fetch()['count'];

// Total answers
$stmt = $pdo->query("SELECT COUNT(*) as count FROM answers");
$stats['answers'] = $stmt->fetch()['count'];

// Total comments
$stmt = $pdo->query("SELECT COUNT(*) as count FROM comments");
$stats['comments'] = $stmt->fetch()['count'];

// Daily activity (today)
$stmt = $pdo->query("SELECT COUNT(*) as count FROM answers WHERE DATE(created_at) = CURDATE()");
$stats['today_answers'] = $stmt->fetch()['count'];

// Recent users (last 5)
$stmt = $pdo->query("SELECT id, name, avatar, created_at FROM users ORDER BY created_at DESC LIMIT 5");
$recent_users = $stmt->fetchAll();

// Recent answers (last 10)
$stmt = $pdo->query("
    SELECT a.*, u.name as user_name, q.question 
    FROM answers a 
    LEFT JOIN users u ON a.user_id = u.id 
    JOIN questions q ON a.question_id = q.id 
    ORDER BY a.created_at DESC 
    LIMIT 10
");
$recent_answers = $stmt->fetchAll();

include 'includes/header.php';
?>

<div class="page-header">
    <h2 class="mb-0">
        <i class="bi bi-speedometer2 text-primary"></i>
        لوحة التحكم الرئيسية
    </h2>
    <p class="text-muted mb-0 mt-2">مرحباً بك في لوحة التحكم</p>
</div>

<!-- Statistics Cards -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="text-muted mb-1 small">المستخدمين</p>
                        <h3 class="mb-0 fw-bold"><?php echo number_format($stats['users']); ?></h3>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary">
                        <i class="bi bi-people"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="text-muted mb-1 small">الأسئلة</p>
                        <h3 class="mb-0 fw-bold"><?php echo number_format($stats['questions']); ?></h3>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success">
                        <i class="bi bi-question-circle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="text-muted mb-1 small">الإجابات</p>
                        <h3 class="mb-0 fw-bold"><?php echo number_format($stats['answers']); ?></h3>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info">
                        <i class="bi bi-check2-circle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-md-3">
        <div class="card stat-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="text-muted mb-1 small">نشاط اليوم</p>
                        <h3 class="mb-0 fw-bold"><?php echo number_format($stats['today_answers']); ?></h3>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning">
                        <i class="bi bi-graph-up"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row g-3">
    <!-- Recent Users -->
    <div class="col-md-6">
        <div class="card">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-people text-primary"></i>
                    أحدث المستخدمين
                </h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>المستخدم</th>
                                <th>تاريخ التسجيل</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($recent_users as $user): ?>
                            <tr>
                                <td>
                                    <span style="font-size: 1.5rem;"><?php echo $user['avatar']; ?></span>
                                    <?php echo htmlspecialchars($user['name']); ?>
                                </td>
                                <td class="text-muted small">
                                    <?php echo date('Y-m-d H:i', strtotime($user['created_at'])); ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Recent Activity -->
    <div class="col-md-6">
        <div class="card">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-activity text-success"></i>
                    آخر النشاطات
                </h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>المستخدم</th>
                                <th>الإجابة</th>
                                <th>الوقت</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($recent_answers as $answer): ?>
                            <tr>
                                <td class="small">
                                    <?php echo htmlspecialchars($answer['user_name'] ?? 'ضيف'); ?>
                                </td>
                                <td>
                                    <?php if ($answer['is_correct']): ?>
                                        <span class="badge bg-success">صحيح</span>
                                    <?php else: ?>
                                        <span class="badge bg-danger">خطأ</span>
                                    <?php endif; ?>
                                </td>
                                <td class="text-muted small">
                                    <?php echo date('H:i', strtotime($answer['created_at'])); ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
