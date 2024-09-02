%hive

-- Criando Tabela
CREATE TABLE campaigns (
    lines BIGINT,
    id_campaign STRING,
    type_campaign STRING,
    days_valid STRING,
    data_campaign STRING,
    channel STRING,
    return_status STRING,
    return_date STRING,
    client_id STRING
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://datasets/campaign_data/'
TBLPROPERTIES ("skip.header.line.count"="1")


-- no comando acima está criando a tabela e inserido os dados com os tipos de cada dado.



-- ====================================================================================================
%hive
-- Criando Tabela
CREATE TABLE purchases (
    purchase_id STRING,
    product_name STRING,
    product_id STRING,
    amount INT,
    price DECIMAL(10, 2),
    discount_applied DOUBLE,
    payment_method STRING,
    purchase_datetime TIMESTAMP,
    purchase_location STRING,
    client_id STRING
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://datasets/purcashe_data/'
TBLPROPERTIES ("skip.header.line.count"="1")

-- no comando acima está criando a tabela e inserido os dados com os tipos de cada dado.
-- ====================================================================================================
%hive

-- Carregando Datasets
LOAD DATA INPATH 's3a://datasets/campaigns_2023_hist.csv' INTO TABLE campaigns

-- neste comando acima esta puxando o arquvi opara exportar os dados.

-- ====================================================================================================
%hive

-- Carregando Datasets
LOAD DATA INPATH 's3a://datasets/purchases_2023.csv' INTO TABLE purchases
-- neste comando acima esta puxando o arquvi opara exportar os dados.

-- ====================================================================================================
%hive
SELECT * FROM purchases

-- no camando acima esta exibindo a tabela que foi criada
-- ====================================================================================================
%hive
SELECT * FROM campaigns

-- no camando acima esta exibindo a tabela que foi criada

-- ====================================================================================================

%hive
-- Query Base para PURCHASES
SELECT
    client_id,
    ROUND(SUM(price * amount * discount_applied), 2) AS total_price,
    MAX(purchase_location) AS most_purchase_location,
    DATE_FORMAT(MIN(purchase_datetime), 'yyyy-MM-dd HH:mm') AS first_purchase,
    DATE_FORMAT(MAX(purchase_datetime), 'yyyy-MM-dd HH:mm') AS last_purchase
FROM purchases
GROUP BY client_id
-- no camando acima esta sendo realizada uma consulta para fornecer as compras do cliente, localização de compra
-- mais frenquente , data e hora de compra

-- ====================================================================================================
%hive

-- Query para most_campaign (Campanha mais recebida pelo cliente)
SELECT 
    client_id, 
    SUM(CASE WHEN return_status != 'error' THEN 1 ELSE 0 END) AS most_campaign,
        SUM(CASE WHEN return_status = 'error' THEN 1 ELSE 0 END) AS quantity_error
FROM 
    campaigns
GROUP BY 
    client_id

-- no camando acima esta sendo realizada uma consulta, selecionando o id do cliente, realiza a consulta de cada cliente em campanhia

-- ====================================================================================================
%hive
-- Query para quantity_error (Quantidade de campanhas que retornaram o status "error")
SELECT
    id_campaign,
    COUNT(*) AS quantity_error
FROM
    campaigns
WHERE
    return_status = 'sms'
GROUP BY
    id_campaign

--está sendo usada para contar o número de ocorrências de um status específico sms nas campanhas, agrupando os resultados por id_campaign.
