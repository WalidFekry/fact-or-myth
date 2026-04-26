<?php
require_once 'includes/auth.php';
require_once 'includes/db.php';

requireLogin();

$pageTitle = 'إدارة التعليقات';
$pdo = getDB();

$success = '';

// Handle Delete
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $id = $_POST['id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM comments WHERE id = ?");
    $stmt->execute([$id]);
    $success = 'تم حذف التعليق بنجاح';
}

// Pagination
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$per_page = 20;
$offset = ($page - 1) * $per_page;

// Get total count
$stmt = $pdo->query("SELECT COUNT(*) as count FROM comments");
$total = $stmt->fetch()['count'];
$total_pages = ceil($total / $per_page);

// Get comments
$stmt = $pdo->prepare("
    SELECT c.*, 
           u.name as user_name, 
           u.avatar as user_avatar,
           q.question
    FROM comments c
    JOIN users u ON c.user_id = u.id
    JOIN questions q ON c.question_id = q.id
    ORDER BY c.created_at DESC
    LIMIT $per_page OFFSET $offset
");
$stmt->execute();
$comments = $stmt->fetchAll();

include 'includes/header.php';
?>

<div class="page-header">
    <h2 class="mb-0">
        <i class="bi bi-chat-dots text-primary"></i>
        إدارة التعليقات
    </h2>
    <p class="text-muted mb-0 mt-2">عرض وحذف التعليقات غير المناسبة</p>
</div>

<?php if ($success): ?>
    <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle-fill"></i>
        <?php echo $success; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<?php endif; ?>

<!-- Comments Table -->
<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th style="width: 150px;">المستخدم</th>
                        <th>التعليق</th>
                        <th style="width: 250px;">السؤال</th>
                        <th style="width: 150px;">التاريخ</th>
                        <th style="width: 100px;">الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($comments as $comment): ?>
                    <tr>
                        <td><?php echo $comment['id']; ?></td>
                        <td>
                            <div class="d-flex align-items-center">
                                <span style="font-size: 1.5rem; margin-left: 8px;"><?php echo $comment['user_avatar']; ?></span>
                                <small><?php echo htmlspecialchars($comment['user_name']); ?></small>
                            </div>
                        </td>
                        <td>
                            <div style="max-width: 300px;">
                                <?php echo htmlspecialchars($comment['comment']); ?>
                            </div>
                        </td>
                        <td>
                            <div style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" class="text-muted small">
                                <?php echo htmlspecialchars($comment['question']); ?>
                            </div>
                        </td>
                        <td class="text-muted small">
                            <?php echo date('Y-m-d H:i', strtotime($comment['created_at'])); ?>
                        </td>
                        <td class="table-actions">
                            <form method="POST" style="display: inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<?php echo $comment['id']; ?>">
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
                <a class="page-link" href="?page=<?php echo $i; ?>">
                    <?php echo $i; ?>
                </a>
            </li>
        <?php endfor; ?>
    </ul>
</nav>
<?php endif; ?>

<?php include 'includes/footer.php'; ?>
