--[[ MADE BY Nyxon#4418 ]]--


--[[ CHAR_BANK_MAZE are replaced by CHAR_BANK_FLEECA ]]--

ESX.StartPayCheck = function()
	function payCheck()
		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			local job     = xPlayer.job.grade_name
			local salary  = xPlayer.job.grade_salary

			if salary > 0 then
				if job == 'unemployed' then
					TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_FLEECA', 9)
				elseif Config.EnableSocietyPayouts then
					TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
						if society ~= nil then
							TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
								if account.money >= salary then
									TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
									account.removeMoney(salary)

									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
								else
									TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_FLEECA', 1)
								end
							end)
						else
							TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
							TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
						end
					end)
				else
					TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
					TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
				end
			end

		end
		SetTimeout(Config.PaycheckInterval, payCheck)
	end

	SetTimeout(Config.PaycheckInterval, payCheck)
end

--[[ MADE BY Nyxon#4418 ]]--