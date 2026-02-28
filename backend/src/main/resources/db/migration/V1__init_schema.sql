CREATE TABLE IF NOT EXISTS users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'USER',
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS wallets (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT         NOT NULL UNIQUE,
    balance    DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    currency   VARCHAR(3)     NOT NULL DEFAULT 'EUR',
    updated_at DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_balance CHECK (balance >= 0)
);

CREATE TABLE IF NOT EXISTS transactions (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    wallet_id      BIGINT         NOT NULL,
    type           VARCHAR(30)    NOT NULL,
    amount         DECIMAL(15, 2) NOT NULL,
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after  DECIMAL(15, 2) NOT NULL,
    reference_id   BIGINT,
    description    VARCHAR(255),
    created_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaction_wallet FOREIGN KEY (wallet_id) REFERENCES wallets(id)
);

CREATE TABLE IF NOT EXISTS seasons (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50)  NOT NULL,
    start_date DATE         NOT NULL,
    end_date   DATE         NOT NULL,
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS teams (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    short_name  VARCHAR(10)  NOT NULL,
    country     VARCHAR(50)  NOT NULL,
    logo_url    VARCHAR(255),
    external_id VARCHAR(50)  UNIQUE,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS matches (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    season_id    BIGINT      NOT NULL,
    home_team_id BIGINT      NOT NULL,
    away_team_id BIGINT      NOT NULL,
    scheduled_at DATETIME    NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    home_score   INT,
    away_score   INT,
    external_id  VARCHAR(100) UNIQUE,
    result       VARCHAR(10),
    round        INT,
    venue        VARCHAR(100),
    created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_season    FOREIGN KEY (season_id)    REFERENCES seasons(id),
    CONSTRAINT fk_match_home_team FOREIGN KEY (home_team_id) REFERENCES teams(id),
    CONSTRAINT fk_match_away_team FOREIGN KEY (away_team_id) REFERENCES teams(id),
    CONSTRAINT chk_different_teams CHECK (home_team_id <> away_team_id)
);

CREATE TABLE IF NOT EXISTS match_odds (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    match_id   BIGINT        NOT NULL,
    bookmaker  VARCHAR(50)   NOT NULL DEFAULT 'BetMaster',
    home_odds  DECIMAL(6, 3) NOT NULL,
    away_odds  DECIMAL(6, 3) NOT NULL,
    margin_pct DECIMAL(5, 2) NOT NULL,
    is_active  BOOLEAN       NOT NULL DEFAULT TRUE,
    valid_from DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until DATETIME,
    source     VARCHAR(30)   NOT NULL DEFAULT 'MANUAL',
    created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_odds_match FOREIGN KEY (match_id) REFERENCES matches(id)
);

CREATE TABLE IF NOT EXISTS tickets (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT         NOT NULL,
    stake         DECIMAL(10, 2) NOT NULL,
    potential_win DECIMAL(10, 2) NOT NULL,
    total_odds    DECIMAL(10, 3) NOT NULL,
    status        VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    ticket_type   VARCHAR(10)    NOT NULL DEFAULT 'SINGLE',
    placed_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at   DATETIME,
    CONSTRAINT fk_ticket_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_stake CHECK (stake > 0)
);

CREATE TABLE IF NOT EXISTS ticket_items (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id     BIGINT        NOT NULL,
    match_id      BIGINT        NOT NULL,
    match_odds_id BIGINT        NOT NULL,
    prediction    VARCHAR(15)   NOT NULL,
    odds_value    DECIMAL(6, 3) NOT NULL,
    status        VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    resolved_at   DATETIME,
    CONSTRAINT fk_item_ticket     FOREIGN KEY (ticket_id)     REFERENCES tickets(id),
    CONSTRAINT fk_item_match      FOREIGN KEY (match_id)      REFERENCES matches(id),
    CONSTRAINT fk_item_match_odds FOREIGN KEY (match_odds_id) REFERENCES match_odds(id)
);