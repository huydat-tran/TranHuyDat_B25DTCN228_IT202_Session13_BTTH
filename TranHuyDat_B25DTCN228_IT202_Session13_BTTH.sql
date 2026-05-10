DELIMITER //

CREATE TRIGGER AutoDeductWallet
BEFORE INSERT ON Service_Usages
FOR EACH ROW
BEGIN

    DECLARE v_price DECIMAL(10,2);
    DECLARE v_balance DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);

    SELECT price
    INTO v_price
    FROM Services
    WHERE service_id = NEW.service_id;

    SET NEW.actual_price = v_price;

    SELECT balance, status
    INTO v_balance, v_status
    FROM Wallets
    WHERE patient_id = NEW.patient_id;


    IF v_status = 'Inactive' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thất bại: Ví trả trước đang bị khóa';
    END IF;

    IF v_balance < v_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thất bại: Số dư ví không đủ để thanh toán';
    END IF;

    UPDATE Wallets
    SET balance = balance - v_price
    WHERE patient_id = NEW.patient_id;

END //

DELIMITER ;