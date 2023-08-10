Utils.Database = {}

function Utils.Database.execute(sql,params)
	MySQL.Sync.execute(sql, params)
end

function Utils.Database.fetchAll(sql,params)
	return MySQL.Sync.fetchAll(sql, params)
end

function Utils.Database.validateTableColumns(tables)
	for table, columns in pairs(tables) do
		if Config.disable_column_check == true then
			local columns_str = "";
			for i, column in pairs(columns) do
				if i == 1 then
					columns_str = columns_str.."`"..column.."`";
				else
					columns_str = columns_str..", `"..column.."`";
				end
			end
			local sql = "SELECT "..columns_str.." FROM `"..table.."` LIMIT 1";
			local query_2 = Utils.Database.fetchAll(sql,{});
			if query_2 == nil then
				error("^1["..GetInvokingResource().."]^3 The table^1"..table.."^3 has some missing columns. Please, delete this table \"^1"..table.."^3\" and restart the server.^7")
			end
		else
			local sql = "SELECT COLUMN_TYPE, DATA_TYPE, COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE FROM `information_schema`.`COLUMNS` WHERE TABLE_SCHEMA = (SELECT DATABASE() AS default_schema) and TABLE_NAME='"..table.."' ORDER BY ORDINAL_POSITION;";
			local query_information_schema = Utils.Database.fetchAll(sql,{});
			for _, column in pairs(columns) do
				local column_found = false
				for k, column_data in pairs(query_information_schema) do
					if column == column_data.COLUMN_NAME then
						column_found = true
						checkExistingColumnType(table,column,column_data)
					end
				end
				if column_found == false then
					fixMissingColumn(table,column)
				end
			end
		end
	end
end

local add_column_sqls = {
	-- Stores
	['store_jobs'] = {
		['trucker_contract_id'] = "ALTER TABLE `store_jobs` ADD COLUMN `trucker_contract_id` INT UNSIGNED NULL DEFAULT NULL AFTER `progress`;",
	},
	-- Trucker
	['trucker_users'] = {
		['dark_theme'] = "ALTER TABLE `trucker_users` ADD COLUMN `dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1' AFTER `loan_notify`;",
		['external_data'] = "ALTER TABLE `trucker_available_contracts` ADD COLUMN `external_data` TEXT NULL DEFAULT NULL AFTER `trailer`;",
		['progress'] = "ALTER TABLE `trucker_available_contracts` ADD COLUMN `progress` TINYINT(2) NOT NULL DEFAULT '0';",
	}
}
function fixMissingColumn(table_name, column_name)
	if add_column_sqls[table_name] and add_column_sqls[table_name][column_name] then
		Utils.Database.execute(add_column_sqls[table_name][column_name])
	else
		error("^1["..GetInvokingResource().."]^3 The table^1"..table.."^3 has some missing columns. Please, delete this table \"^1"..table.."^3\" and restart the server.^7")
	end
end

--[[
	SELECT COLUMN_TYPE, DATA_TYPE, COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE FROM `information_schema`.`COLUMNS` 
	WHERE TABLE_SCHEMA = (SELECT DATABASE() AS default_schema) 
	AND TABLE_NAME='nome_tabela' 
	AND COLUMN_NAME='nome_coluna'
	ORDER BY ORDINAL_POSITION;
]]
local change_table_sqls = {
	-- Trucker
	['trucker_available_contracts'] = {
		['progress'] = {
			['sql'] = "ALTER TABLE `trucker_available_contracts` CHANGE COLUMN `progress` `progress` VARCHAR(50) NULL DEFAULT NULL AFTER `external_data`;",
			['DATA_TYPE'] = 'varchar',
			['COLUMN_TYPE'] = 'varchar(50)',
			['COLUMN_DEFAULT'] = "NULL",
			['IS_NULLABLE'] = 'YES', -- YES | NO
			['COLUMN_NAME'] = 'progress'
		}
	}
}
function checkExistingColumnType(table_name, column_name, column_data)
	if change_table_sqls[table_name] and change_table_sqls[table_name][column_name] then
		local change_table_sql = change_table_sqls[table_name][column_name]
		local is_outdated = false
		for k, v in pairs(column_data) do
			if change_table_sql[k] ~= v then
				is_outdated = true
			end
		end
		if is_outdated then
			Utils.Database.execute(change_table_sql.sql)
		end
	end
end