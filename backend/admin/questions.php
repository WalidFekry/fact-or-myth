<?php
require_once 'includes/auth.php';
require_once 'includes/db.php';

requireLogin();

$pageTitle = 'إدارة الأسئلة';
$pdo = getDB();

$success = '';
$error = '';

// Handle Add/Edit/Delete
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'add' || $action === 'edit') {
        $id = $_POST['id'] ?? null;
        $question = trim($_POST['question'] ?? '');
        $correct_answer = isset($_POST['correct_answer']) ? (int)$_POST['correct_answer'] : 0;
        $explanation = trim($_POST['explanation'] ?? '');
        $category = trim($_POST['category'] ?? '');
        $is_daily = isset($_POST['is_daily']) ? 1 : 0;
        
        if (empty($question) || empty($explanation) || empty($category)) {
            $error = 'جميع الحقول مطلوبة';
        } else {
            if ($action === 'add') {
                $stmt = $pdo->prepare("
                    INSERT INTO questions (question, correct_answer, explanation, category, is_daily) 
                    VALUES (?, ?, ?, ?, ?)
                ");
                $stmt->execute([$question, $correct_answer, $explanation, $category, $is_daily]);
                $success = 'تم إضافة السؤال بنجاح';
            } else {
                $stmt = $pdo->prepare("
                    UPDATE questions 
                    SET question = ?, correct_answer = ?, explanation = ?, category = ?, is_daily = ? 
                    WHERE id = ?
                ");
                $stmt->execute([$question, $correct_answer, $explanation, $category, $is_daily, $id]);
                $success = 'تم تحديث السؤال بنجاح';
            }
        }
    } elseif ($action === 'delete') {
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("DELETE FROM questions WHERE id = ?");
        $stmt->execute([$id]);
        $success = 'تم حذف السؤال بنجاح';
    }
}

// Pagination
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$per_page = 15;
$offset = ($page - 1) * $per_page;

// Search
$search = $_GET['search'] ?? '';
$where = '';
$params = [];

if ($search) {
    $where = "WHERE question LIKE ? OR explanation LIKE ? OR category LIKE ?";
    $search_term = "%$search%";
    $params = [$search_term, $search_term, $search_term];
}

// Get total count
$stmt = $pdo->prepare("SELECT COUNT(*) as count FROM questions $where");
$stmt->execute($params);
$total = $stmt->fetch()['count'];
$total_pages = ceil($total / $per_page);

// Get questions
$stmt = $pdo->prepare("
    SELECT q.*, 
           (SELECT COUNT(*) FROM answers WHERE question_id = q.id) as answer_count
    FROM questions q 
    $where
    ORDER BY q.created_at DESC 
    LIMIT $per_page OFFSET $offset
");
$stmt->execute($params);
$questions = $stmt->fetchAll();

// Get question for editing
$edit_question = null;
if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM questions WHERE id = ?");
    $stmt->execute([$_GET['edit']]);
    $edit_question = $stmt->fetch();
}

include 'includes/header.php';
?>

<div class="page-header d-flex justify-content-between align-items-center">
    <div>
        <h2 class="mb-0">
            <i class="bi bi-question-circle text-primary"></i>
            إدارة الأسئلة
        </h2>
        <p class="text-muted mb-0 mt-2">إضافة وتعديل وحذف الأسئلة</p>
    </div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#questionModal">
        <i class="bi bi-plus-circle"></i>
        إضافة سؤال جديد
    </button>
</div>

<?php if ($success): ?>
    <div class="alert alert-success alert-dismissible fade show">
        <i class="bi bi-check-circle-fill"></i>
        <?php echo $success; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<?php endif; ?>

<?php if ($error): ?>
    <div class="alert alert-danger alert-dismissible fade show">
        <i class="bi bi-exclamation-triangle-fill"></i>
        <?php echo $error; ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<?php endif; ?>

<!-- Search -->
<div class="card mb-3">
    <div class="card-body">
        <form method="GET" class="row g-3">
            <div class="col-md-10">
                <input type="text" name="search" class="form-control" placeholder="بحث في الأسئلة..." value="<?php echo htmlspecialchars($search); ?>">
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

<!-- Questions Table -->
<div class="card">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th>السؤال</th>
                        <th style="width: 100px;">الإجابة</th>
                        <th style="width: 120px;">القسم</th>
                        <th style="width: 80px;">يومي</th>
                        <th style="width: 80px;">إجابات</th>
                        <th style="width: 150px;">الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($questions as $q): ?>
                    <tr>
                        <td><?php echo $q['id']; ?></td>
                        <td>
                            <div style="max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                <?php echo htmlspecialchars($q['question']); ?>
                            </div>
                        </td>
                        <td>
                            <?php if ($q['correct_answer']): ?>
                                <span class="badge bg-success">حقيقة</span>
                            <?php else: ?>
                                <span class="badge bg-danger">خرافة</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <span class="badge bg-info"><?php echo htmlspecialchars($q['category']); ?></span>
                        </td>
                        <td>
                            <?php if ($q['is_daily']): ?>
                                <i class="bi bi-check-circle-fill text-success"></i>
                            <?php else: ?>
                                <i class="bi bi-x-circle text-muted"></i>
                            <?php endif; ?>
                        </td>
                        <td class="text-center">
                            <span class="badge bg-secondary"><?php echo $q['answer_count']; ?></span>
                        </td>
                        <td class="table-actions">
                            <a href="?edit=<?php echo $q['id']; ?>" class="btn btn-sm btn-warning" data-bs-toggle="modal" data-bs-target="#questionModal">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <form method="POST" style="display: inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<?php echo $q['id']; ?>">
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

<!-- Add/Edit Modal -->
<div class="modal fade" id="questionModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <?php echo $edit_question ? 'تعديل السؤال' : 'إضافة سؤال جديد'; ?>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <input type="hidden" name="action" value="<?php echo $edit_question ? 'edit' : 'add'; ?>">
                    <?php if ($edit_question): ?>
                        <input type="hidden" name="id" value="<?php echo $edit_question['id']; ?>">
                    <?php endif; ?>
                    
                    <div class="mb-3">
                        <label class="form-label">نص السؤال *</label>
                        <textarea name="question" class="form-control" rows="3" required><?php echo $edit_question ? htmlspecialchars($edit_question['question']) : ''; ?></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">الإجابة الصحيحة *</label>
                        <select name="correct_answer" class="form-select" required>
                            <option value="1" <?php echo ($edit_question && $edit_question['correct_answer']) ? 'selected' : ''; ?>>حقيقة ✓</option>
                            <option value="0" <?php echo ($edit_question && !$edit_question['correct_answer']) ? 'selected' : ''; ?>>خرافة ✗</option>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">التفسير *</label>
                        <textarea name="explanation" class="form-control" rows="3" required><?php echo $edit_question ? htmlspecialchars($edit_question['explanation']) : ''; ?></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">القسم *</label>
                        <select name="category" class="form-select" required>
                            <option value="">اختر القسم</option>
                            <option value="صحة" <?php echo ($edit_question && $edit_question['category'] === 'صحة') ? 'selected' : ''; ?>>صحة</option>
                            <option value="معلومات عامة" <?php echo ($edit_question && $edit_question['category'] === 'معلومات عامة') ? 'selected' : ''; ?>>معلومات عامة</option>
                            <option value="نفسية" <?php echo ($edit_question && $edit_question['category'] === 'نفسية') ? 'selected' : ''; ?>>نفسية</option>
                            <option value="دينية" <?php echo ($edit_question && $edit_question['category'] === 'دينية') ? 'selected' : ''; ?>>دينية</option>
                            <option value="تكنولوجيا" <?php echo ($edit_question && $edit_question['category'] === 'تكنولوجيا') ? 'selected' : ''; ?>>تكنولوجيا</option>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <div class="form-check">
                            <input type="checkbox" name="is_daily" class="form-check-input" id="is_daily" <?php echo ($edit_question && $edit_question['is_daily']) ? 'checked' : ''; ?>>
                            <label class="form-check-label" for="is_daily">
                                سؤال يومي
                            </label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-circle"></i>
                        <?php echo $edit_question ? 'تحديث' : 'إضافة'; ?>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php if ($edit_question): ?>
<script>
    // Auto-open modal if editing
    window.addEventListener('DOMContentLoaded', function() {
        var modal = new bootstrap.Modal(document.getElementById('questionModal'));
        modal.show();
    });
</script>
<?php endif; ?>

<?php include 'includes/footer.php'; ?>
