-- Initialize sample database with test data

-- Create longitudinal data table
CREATE TABLE longitudinal_data (
    id INTEGER,
    time NUMERIC,
    outcome NUMERIC,
    treatment INTEGER,
    age NUMERIC,
    sex INTEGER
);

-- Create survival data table
CREATE TABLE survival_data (
    id INTEGER,
    time_to_event NUMERIC,
    event INTEGER,
    treatment INTEGER,
    age NUMERIC,
    sex INTEGER
);

-- Insert sample longitudinal data
INSERT INTO longitudinal_data (id, time, outcome, treatment, age, sex) VALUES
(1, 0, 10.2, 0, 25, 1),
(1, 1, 12.1, 0, 25, 1),
(1, 2, 13.5, 0, 25, 1),
(1, 3, 14.2, 0, 25, 1),
(2, 0, 9.8, 1, 30, 0),
(2, 1, 11.2, 1, 30, 0),
(2, 2, 12.8, 1, 30, 0),
(3, 0, 8.5, 0, 45, 1),
(3, 1, 10.1, 0, 45, 1),
(3, 2, 11.0, 0, 45, 1),
(3, 3, 12.2, 0, 45, 1),
(3, 4, 13.1, 0, 45, 1),
(4, 0, 11.2, 1, 35, 0),
(4, 1, 13.5, 1, 35, 0),
(4, 2, 15.1, 1, 35, 0),
(5, 0, 7.8, 0, 55, 1),
(5, 1, 9.2, 0, 55, 1);

-- Insert sample survival data
INSERT INTO survival_data (id, time_to_event, event, treatment, age, sex) VALUES
(1, 5.2, 1, 0, 25, 1),
(2, 3.1, 0, 1, 30, 0),
(3, 7.5, 1, 0, 45, 1),
(4, 4.2, 0, 1, 35, 0),
(5, 2.8, 1, 0, 55, 1);

-- Create indexes for better performance
CREATE INDEX idx_longitudinal_id ON longitudinal_data(id);
CREATE INDEX idx_survival_id ON survival_data(id);
