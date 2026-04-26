-- Sample Data for حقيقة ولا خرافة؟
-- Run this after database.sql to populate with sample questions

USE waliamlr_fact;

-- Clear existing data (optional)
-- TRUNCATE TABLE comments;
-- TRUNCATE TABLE answers;
-- TRUNCATE TABLE streaks;
-- TRUNCATE TABLE questions;
-- TRUNCATE TABLE users;

-- Sample Daily Questions (one per day)
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('شرب 8 أكواب من الماء يومياً ضروري للجميع', FALSE, 'هذا ليس صحيحاً للجميع. احتياجات الماء تختلف حسب الوزن والنشاط والمناخ. الأفضل الاستماع لجسمك والشرب عند الشعور بالعطش.', 'صحة', TRUE, CURDATE()),
('القهوة تسبب الجفاف', FALSE, 'القهوة لا تسبب الجفاف. رغم أنها مدرة للبول، إلا أن السوائل فيها تعوض ذلك. الدراسات أثبتت أن القهوة تساهم في ترطيب الجسم.', 'صحة', TRUE, DATE_ADD(CURDATE(), INTERVAL 1 DAY)),
('البرق لا يضرب نفس المكان مرتين', FALSE, 'البرق يمكن أن يضرب نفس المكان عدة مرات. برج إمباير ستيت يُضرب حوالي 25 مرة سنوياً. الأماكن المرتفعة أكثر عرضة للبرق.', 'معلومات عامة', TRUE, DATE_ADD(CURDATE(), INTERVAL 2 DAY));

-- Sample Free Questions - Health Category
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('تناول الجزر يحسن النظر بشكل كبير', FALSE, 'الجزر يحتوي على فيتامين A المفيد للعين، لكنه لا يحسن النظر بشكل كبير. هذه الخرافة انتشرت في الحرب العالمية الثانية.', 'صحة', FALSE, NULL),
('النوم 8 ساعات يومياً ضروري للجميع', FALSE, 'احتياجات النوم تختلف من شخص لآخر. البعض يحتاج 7 ساعات والبعض 9 ساعات. المهم جودة النوم وليس فقط الكمية.', 'صحة', FALSE, NULL),
('التمارين الرياضية تقوي جهاز المناعة', TRUE, 'التمارين المنتظمة تعزز جهاز المناعة وتقلل من خطر الأمراض. لكن التمارين المفرطة قد تضعف المناعة مؤقتاً.', 'صحة', FALSE, NULL),
('الماء البارد يحرق سعرات حرارية أكثر', TRUE, 'الجسم يحرق سعرات حرارية إضافية لتدفئة الماء البارد، لكن الفرق بسيط جداً ولا يؤثر بشكل كبير على الوزن.', 'صحة', FALSE, NULL);

-- Sample Free Questions - General Knowledge
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('الصين هي أكبر دولة في العالم من حيث المساحة', FALSE, 'روسيا هي أكبر دولة في العالم من حيث المساحة، تليها كندا ثم الولايات المتحدة ثم الصين.', 'معلومات عامة', FALSE, NULL),
('الشمس نجم وليست كوكب', TRUE, 'الشمس نجم متوسط الحجم يقع في مركز المجموعة الشمسية. الكواكب تدور حولها بما فيها الأرض.', 'معلومات عامة', FALSE, NULL),
('الماس يتكون من الكربون المضغوط', TRUE, 'الماس يتكون من ذرات الكربون المرتبة بشكل بلوري تحت ضغط وحرارة عاليين في باطن الأرض.', 'معلومات عامة', FALSE, NULL),
('البشر يستخدمون 10% فقط من أدمغتهم', FALSE, 'هذه خرافة شائعة. نستخدم معظم أجزاء الدماغ، وحتى أثناء النوم يكون الدماغ نشطاً في مناطق مختلفة.', 'معلومات عامة', FALSE, NULL);

-- Sample Free Questions - Psychology
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('الموسيقى تؤثر على المزاج والإنتاجية', TRUE, 'الدراسات أثبتت أن الموسيقى تؤثر على الحالة المزاجية والتركيز. الموسيقى الهادئة تساعد على الاسترخاء والموسيقى النشطة تحفز الطاقة.', 'نفسية', FALSE, NULL),
('الألوان تؤثر على المشاعر والسلوك', TRUE, 'علم نفس الألوان يدرس تأثير الألوان على المشاعر. الأزرق يهدئ، الأحمر يحفز، الأخضر يريح العين.', 'نفسية', FALSE, NULL),
('الضحك يقلل من التوتر', TRUE, 'الضحك يفرز هرمونات السعادة ويقلل من هرمونات التوتر. له فوائد صحية ونفسية عديدة.', 'نفسية', FALSE, NULL),
('الكتابة عن المشاعر تساعد في التعافي النفسي', TRUE, 'الكتابة التعبيرية تساعد في معالجة المشاعر والتخلص من التوتر. تستخدم في العلاج النفسي.', 'نفسية', FALSE, NULL);

-- Sample Free Questions - Religious
INSERT INTO questions (question, correct_answer, explanation, category, is_daily, date) VALUES
('قراءة القرآن تجلب السكينة والطمأنينة', TRUE, 'قال تعالى: "الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ". القرآن له تأثير مهدئ على النفس.', 'دينية', FALSE, NULL),
('الصلاة تحسن الصحة النفسية والجسدية', TRUE, 'الصلاة تجمع بين التأمل والحركة والذكر، مما له فوائد نفسية وجسدية عديدة. الدراسات أثبتت فوائدها الصحية.', 'دينية', FALSE, NULL),
('الصدقة تزيد الرزق', TRUE, 'قال النبي ﷺ: "ما نقصت صدقة من مال". الصدقة لها بركة في المال والحياة.', 'دينية', FALSE, NULL),
('الدعاء يغير القدر', TRUE, 'قال النبي ﷺ: "لا يرد القضاء إلا الدعاء". الدعاء من أعظم العبادات وله تأثير على القدر بإذن الله.', 'دينية', FALSE, NULL);

-- Sample Users (for testing)
INSERT INTO users (name, avatar) VALUES
('أحمد', '👨'),
('فاطمة', '👩'),
('محمد', '🧔'),
('سارة', '👩‍💼'),
('خالد', '👨‍💼');

-- Initialize streaks for sample users
INSERT INTO streaks (user_id, current_streak, last_answer_date)
SELECT id, 0, NULL FROM users;

-- Sample answers (for testing leaderboard)
-- User 1: 8 correct, 2 wrong
INSERT INTO answers (user_id, question_id, answer, is_correct, created_at) VALUES
(1, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(1, 2, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(1, 3, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(1, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(1, 2, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, 3, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(1, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(1, 2, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 3, TRUE, FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 1, TRUE, FALSE, NOW());

-- User 2: 7 correct, 3 wrong
INSERT INTO answers (user_id, question_id, answer, is_correct, created_at) VALUES
(2, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(2, 2, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(2, 3, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(2, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(2, 2, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 3, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 1, FALSE, TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(2, 2, TRUE, FALSE, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 3, TRUE, FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(2, 1, TRUE, FALSE, NOW());

-- Update streaks
UPDATE streaks SET current_streak = 10, last_answer_date = CURDATE() WHERE user_id = 1;
UPDATE streaks SET current_streak = 10, last_answer_date = CURDATE() WHERE user_id = 2;

SELECT 'Sample data inserted successfully!' as message;
