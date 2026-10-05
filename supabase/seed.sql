-- SkillPath Demo Dataset for Hackathon Evaluation

INSERT INTO public.trades (id, name, name_tamil, description, description_tamil, nsqf_level, sector) VALUES
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', 'CNC Operator', 'CNC ஆப்பரேட்டர்', 'Operates computer numerical control machines to fabricate parts.', 'பாகங்களை உருவாக்க கணினி எண் கட்டுப்பாட்டு இயந்திரங்களை இயக்குகிறார்.', 4, 'Manufacturing'),
('5de5837d-1db9-4089-a2e6-7313bd855cca', 'Electrician', 'எலக்ட்ரீஷியன்', 'Installs, maintains, and repairs electrical wiring, equipment, and fixtures.', 'மின் இணைப்புகள், உபகரணங்கள் மற்றும் சாதனங்களை நிறுவி பராமரிக்கிறார்.', 4, 'Construction'),
('0eec711a-0e9e-4eec-893c-2374e5088eb4', 'Solar Technician', 'சோலார் டெக்னீஷியன்', 'Installs and maintains solar panel systems.', 'சூரிய ஒளி தகடு அமைப்புகளை நிறுவி பராமரிக்கிறார்.', 4, 'Renewable Energy'),
('6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde', 'Fitter', 'ஃபிட்டர்', 'Assembles and fits fabricated parts into products.', 'உருவாக்கப்பட்ட பாகங்களை தயாரிப்புகளில் இணைத்து அமைக்கிறார்.', 4, 'Manufacturing');

INSERT INTO public.training_providers (id, name, district, city, state, verified) VALUES
('37f96c21-1c52-4fc5-a9f9-e414c2b9a71a', 'Salem Skill Center', 'Salem', 'Salem', 'Tamil Nadu', true),
('e9b06a5b-d5ce-4122-b5ec-8933b9cfbce5', 'Coimbatore Tech Institute', 'Coimbatore', 'Coimbatore', 'Tamil Nadu', true),
('d2bcbdf7-c8bf-4c7b-91cc-a75d506ab9bc', 'Chennai Vocational Academy', 'Chennai', 'Chennai', 'Tamil Nadu', true);

INSERT INTO public.outcomes (trade_id, provider_id, district, placement_rate, min_salary, max_salary, average_salary, sample_size, data_year, verified, source) VALUES
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', '37f96c21-1c52-4fc5-a9f9-e414c2b9a71a', 'Salem', 82, 16000, 20000, 18000, 420, 2026, true, 'Hackathon Demo Dataset'),
('5de5837d-1db9-4089-a2e6-7313bd855cca', 'e9b06a5b-d5ce-4122-b5ec-8933b9cfbce5', 'Coimbatore', 85, 15000, 22000, 17500, 500, 2026, true, 'Hackathon Demo Dataset'),
('0eec711a-0e9e-4eec-893c-2374e5088eb4', 'd2bcbdf7-c8bf-4c7b-91cc-a75d506ab9bc', 'Chennai', 90, 18000, 28000, 21000, 310, 2026, true, 'Hackathon Demo Dataset'),
('6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde', '37f96c21-1c52-4fc5-a9f9-e414c2b9a71a', 'Salem', 78, 14000, 19000, 16000, 380, 2026, true, 'Hackathon Demo Dataset');

INSERT INTO public.career_paths (trade_id, step_number, title, title_tamil, description) VALUES
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', 1, 'Vocational Training', 'தொழிற்பயிற்சி', 'Complete 1-2 years of ITI training.'),
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', 2, 'Junior CNC Operator', 'இளநிலை CNC ஆப்பரேட்டர்', 'Entry-level position.'),
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', 3, 'Senior CNC Operator', 'முதுநிலை CNC ஆப்பரேட்டர்', 'Requires 2-4 years of experience.'),
('b305221c-43db-4cc9-b7b5-0c58e727dbf8', 4, 'Shift Supervisor', 'சிப்ட் சூப்பர்வைசர்', 'Requires leadership skills and 5+ years experience.');
