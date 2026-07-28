-- PostgreSQL 测试数据 — 首页公告弹窗
-- 插入测试公告，清理 admin 用户的已读记录以便弹窗触发

INSERT INTO sys_notice (notice_title, notice_type, notice_content, status, create_by, create_time, remark)
VALUES
('系统升级通知', '1', '<p>系统将于本周五 22:00-24:00 进行升级维护，届时将暂停服务，请提前保存数据。</p>', '0', 'admin', NOW(), ''),
('2026年度总结大会公告', '2', '<p>公司将于 2026年8月15日 召开年度总结大会，请各部门提前准备汇报材料。</p><p>地点：三楼会议室</p><p>时间：14:00</p>', '0', 'admin', NOW(), '');

-- 清理 admin 用户对这两条公告的已读记录（如果存在）
DELETE FROM sys_notice_read WHERE user_id = 1 AND notice_id IN (
  SELECT notice_id FROM sys_notice WHERE notice_title IN ('系统升级通知', '2026年度总结大会公告')
);