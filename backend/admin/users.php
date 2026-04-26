<?php
require_once 'includes/auth.php';
require_once 'includes/db.php';

requireLogin();

$pageTitle = 'إدارة المستخدمين';
$pdo = getDB();

$success = '';

// Handle Delete
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $id = $_POST['id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
    $stmt->execute([$id]);
    $success = 'تم حذف المستخدم بنجاح';
}

// Pagination
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$per_page = 20;
$offset = ($page - 1) * $per_page;

// Search
$search = $_GET['search'] ?? '';
$where = '';
$params = [];

if ($search) {
    $where = "WHERE u.name LIKE ?";
    $params = ["%$search%"];
}

// Get total count
$stmt = $pdo->prepare("SELECT COUNT(*) as count FROM users u $where");
$stmt->execute($params);
$total = $stmt->fetch()['count'];
$total_pages = ceil($total / $per_page);

// Get users with stats
$stmt = $pdo->prepare("
    SELECT u.*,
           COUNT(DISTINCT a.id) as total_answers,
           SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
           SUM(CASE WHEN a.is_correct = 0 THEN 1 ELSE 0 END) as wrong_answers,
           COALESCE(s.current_streak, 0) as current_streak
    FROM users u
    LEFT JOIN answers a ON u.id = a.user_id
    LEFT JOIN streaks s ON u.id = s.user_id
    $where
    GROUP BY u.id
    ORDER BY u.created_at DESC
    LIMIT $per_page OFFSET $offset
");
$stmt->execute($params);
$users = $stmt->fetchAll();

include 'includes/header.php';
?>

<div class="page-header">
    <h2 class="mb-0">
        <i class="bi bi-people text-primary"></i>
        إدارة المستخدمين
    </h2>
    <p class="text-muted mb-0 mt-2">عرض وإدارة المستخدمين</p>
</div>

<?php if ($success): ?>
    <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle-fill"></i>
        <?php echo $success; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<?php endif; ?>

<!-- Search -->
<div class="card mb-3">
    <div class="card-body">
        <form method="GET" class="row g-3">
            <div class="col-md-10">
                <input type="text" name="search" class="form-control" placeholder="بحث عن مستخدم..." value="<?php echo htmlspecialchars($search); ?>">
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-search"></i>
                    بحث
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Users Table -->
<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th>المستخدم</th>
                        <th style="width: 100px;">إجمالي</th>
                        <th style="width: 100px;">صحيحة</th>
                        <th style="width: 100px;">خاطئة</th>
                        <th style="width: 100px;">الدقة</th>
                        <th style="width: 80px;">السلسلة</th>
                        <th style="width: 150px;">تاريخ التسجيل</th>
                        <th style="width: 100px;">الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $user): ?>
                    <?php
                        $accuracy = $user['total_answers'] > 0 
                            ? round(($user['correct_answers'] / $user['total_answers']) * 100, 1) 
                            : 0;
                    ?>
                    <tr>
                        <td><?php echo $user['id']; ?></td>
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
                            <span class="badge bg-info"><?php echo $accuracy; ?>%</span>
                        </td>
                        <td class="text-center">
                            <?php if ($user['current_streak'] > 0): ?>
                                <span class="badge bg-warning">🔥 <?php echo $user['current_streak']; ?></span>
                            <?php else: ?>
                                <span class="text-muted">-</span>
                            <?php endif; ?>
                        </td>
                        <td class="text-muted small">
                            <?php echo date('Y-m-d', strtotime($user['created_at'])); ?>
                        </td>
                        <td class="table-actions">
                            <form method="POST" style="display: inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<?php echo $user['id']; ?>">
                                <button type="submit" class="btn btn-sm btn-danger btn-delete">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Pagination -->
<?php if ($total_pages > 1): ?>
<nav class="mt-3">
    <ul class="pagination justify-content-center">
        <?php for ($i = 1; $i <= $total_pages; $i++): ?>
            <li class="page-item <?php echo $i === $page ? 'active' : ''; ?>">
                <a class="page-link" href="?page=<?php echo $i; ?><?php echo $search ? '&search=' . urlencode($search) : ''; ?>">
                    <?php echo $i; ?>
                </a>
            </li>
        <?php endfor; ?>
    </ul>
</nav>
<?php endif; ?>

<?php include 'includes/footer.php'; ?>
