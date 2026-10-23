-- All names, amounts and events in this lab are fictional.
INSERT INTO invoices VALUES
 ('north','i-1',1200),('north','i-2',800),('south','i-1',500),('south','i-3',300);
INSERT INTO payment_events VALUES
 (1,'north','e-paid','p-1','i-1',2,'settled',1200,'2026-01-02T00:00:00Z'),
 (2,'north','e-paid','p-1','i-1',2,'settled',1200,'2026-01-02T00:01:00Z'),
 (3,'north','e-pending','p-1','i-1',1,'pending',1200,'2026-01-04T00:00:00Z'),
 (4,'north','e-refund','p-2','i-2',3,'refunded',800,'2026-01-03T00:00:00Z'),
 (5,'north','e-settle','p-2','i-2',2,'settled',800,'2026-01-05T00:00:00Z'),
 (6,'south','e-paid','p-1','i-1',2,'settled',550,'2026-01-02T00:00:00Z'),
 (7,'south','e-wait','p-3','i-3',1,'pending',300,'2026-01-02T00:00:00Z');
