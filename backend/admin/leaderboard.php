<?php
require_once 'includes/auth.php';
require_once 'includes/db.php';

requireLogin();

$pageTitle = 'المتصدرين';
$pdo = getDB();

// Get leaderboard (same logic as app)
$stmt = $pdo->query("
    SELECT 
        u.id,
        u.name,
        u.avatar,
        COUNT(a.id) as total_answers,
        SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
        SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_answers,
        ROUND((SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) / COUNT(a.id)) * 100, 2) as accuracy,
        COALESCE(s.current_streak, 0) as current_streak
    FROM users u
    LEFT JOIN answers a ON u.id = a.user_id
    LEFT JOIN streaks s ON u.id = s.user_id
    GROUP BY u.id
    HAVING total_answers >= 5
    ORDER BY correct_answers DESC, accuracy DESC
    LIMIT 50
");
$leaderboard = $stmt->fetchAll();

include 'includes/header.php';
?>

<div class="page-header">
    <h2 class="mb-0">
        <i class="bi bi-trophy text-warning"></i>
        المتصدرين
    </h2>
    <p class="text-muted mb-0 mt-2">أفضل 50 مستخدم (الحد الأدنى 5 إجابات)</p>
</div>

<!-- Leaderboard Table -->
<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 60px;">الترتيب</th>
                        <th>المستخدم</th>
                        <th style="width: 100px;">إجمالي</th>
                        <th style="width: 100px;">صحيحة</th>
                        <th style="width: 100px;">خاطئة</th>
                        <th style="width: 100px;">الدقة</th>
                        <th style="width: 80px;">السلسلة</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $rank = 1;
                    foreach ($leaderboard as $user): 
                    ?>
                    <tr>
                        <td>
                            <?php if ($rank === 1): ?>
                                <span class="badge" style="background: linear-gradient(135deg, #FFD700, #FFA500); color: white; font-size: 1rem;">
                                    🥇 <?php echo $rank; ?>
                                </span>
                            <?php elseif ($rank === 2): ?>
                                <span class="badge" style="background: linear-gradient(135deg, #C0C0C0, #A8A8A8); color: white; font-size: 1rem;">
                                    🥈 <?php echo $rank; ?>
                                </span>
                            <?php elseif ($rank === 3): ?>
                                <span class="badge" style="background: linear-gradient(135deg, #CD7F32, #B87333); color: white; font-size: 1rem;">
                                    🥉 <?php echo $rank; ?>
                                </span>
                            <?php else: ?>
                                <span class="badge bg-secondary"><?php echo $rank; ?></span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <div class="d-flex align-items-center">
                                <span style="font-size: 1.8rem; margin-left: 10px;"><?php echo $user['avatar']; ?></span>
                                <strong><?php echo htmlspecialchars($user['name']); ?></strong>
                            </div>
                        </td>
                        <td>
                            <span class="badge bg-primary"><?php echo $user['total_answers']; ?></span>
                        </td>
                        <td>
                            <span class="badge bg-success"><?php echo $user['correct_answers']; ?></span>
                        </td>
                        <td>
                            <span class="badge bg-danger"><?php echo $user['wrong_answers']; ?></span>
                        </td>
                        <td>
                            <span class="badge bg-info"><?php echo $user['accuracy']; ?>%</span>
                        </td>
                        <td class="text-center">
                            <?php if ($user['current_streak'] > 0): ?>
                                <span class="badge bg-warning">🔥 <?php echo $user['current_streak']; ?></span>
                            <?php else: ?>
                                <span class="text-muted">-</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php 
                    $rank++;
                    endforeach; 
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php if (empty($leaderboard)): ?>
<div class="text-center py-5">
    <i class="bi bi-trophy" style="font-size: 4rem; color: #ddd;"></i>
    <p class="text-muted mt-3">لا يوجد مستخدمين في المتصدرين بعد</p>
</div>
<?php endif; ?>

<?php include 'includes/footer.php'; ?>
