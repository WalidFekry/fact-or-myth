-- Database Schema for حقيقة ولا خرافة؟

CREATE DATABASE IF NOT EXISTS waliamlr_fact CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE waliamlr_fact;

-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    avatar VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Questions Table
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL,
    correct_answer BOOLEAN NOT NULL,
    explanation TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    is_daily BOOLEAN DEFAULT FALSE,
    date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_is_daily (is_daily),
    INDEX idx_date (date),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Answers Table
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    question_id INT NOT NULL,
    answer BOOLEAN NOT NULL,
    is_correct BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_user_question (user_id, question_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments Table
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_question (question_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Streaks Table
CREATE TABLE streaks (
    user_id INT PRIMARY KEY,
    current_streak INT DEFAULT 0,
    last_answer_date DATE NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample Data
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('شرب 8 أكواب من الماء يومياً ضروري للجميع', FALSE, 'هذا ليس صحيحاً للجميع. احتياجات الماء تختلف حسب الوزن والنشاط والمناخ.', 'صحة', TRUE, CURDATE()),
('القهوة تسبب الجفاف', FALSE, 'القهوة لا تسبب الجفاف. رغم أنها مدرة للبول، إلا أن السوائل فيها تعوض ذلك.', 'صحة', FALSE, NULL),
('البرق لا يضرب نفس المكان مرتين', FALSE, 'البرق يمكن أن يضرب نفس المكان عدة مرات. برج إمباير ستيت يُضرب حوالي 25 مرة سنوياً.', 'معلومات عامة', FALSE, NULL),
('الإنسان يستخدم 10% فقط من دماغه', FALSE, 'هذه خرافة شائعة. نستخدم معظم أجزاء الدماغ، وحتى أثناء النوم يكون الدماغ نشطاً.', 'نفسية', FALSE, NULL),
('قراءة القرآن تجلب السكينة والطمأنينة', TRUE, 'قال تعالى: "الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ"', 'دينية', FALSE, NULL);
