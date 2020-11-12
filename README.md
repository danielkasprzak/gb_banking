# gb_banking | 2.1

### How to install?

- Put `gb_banking` in your `resources` folder.
- Add `start gb_banking` in your `server.cfg` file.
- Import `gb_banking.sql` into your database.

### How to change language?

> Config file

### Shops function

> Client

```

function OpenShopMenu(zone)
	PlayerData = ESX.GetPlayerData()

	local elements = {}
	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label      = item.label .. ' - <span style="color: green;">$' .. item.price .. '</span>',
			label_real = item.label,
			item       = item.item,
			price      = item.price,

			-- menu properties
			value      = 1,
			type       = 'slider',
			min        = 1,
			max        = item.limit
		})
	end

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title    = _U('shop'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title    = _U('shop_confirm', data.current.value, data.current.label_real, data.current.price * data.current.value),
			align    = 'bottom-right',
			elements = {
				{label = _U('no'),  value = 'no'},
				{label = _U('yes'), value = 'yes'}
			}
		}, function(data2, menu2)
			if data2.current.value == 'yes' then
                -- THIS

				DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 10)
					while (UpdateOnscreenKeyboard() == 0) do
						DisableAllControlActions(0);
						Wait(0);
					end
				if (GetOnscreenKeyboardResult()) then
					local result = GetOnscreenKeyboardResult()
					if string.len(result) > 0 then
						DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 4)
						while (UpdateOnscreenKeyboard() == 0) do
							DisableAllControlActions(0);
							Wait(0);
						end
						if (GetOnscreenKeyboardResult()) then
							local result1 = GetOnscreenKeyboardResult()
							if string.len(result1) > 0 then
								TriggerServerEvent('atm:login', result, result1, data.current.item, data.current.value, zone)
							else
								DisplayOnscreenKeyboard(0, "FMMC_MPM_NA", "", "", "", "", "", 30)
							end
						end
					else
						DisplayOnscreenKeyboard(0, "FMMC_MPM_NA", "", "", "", "", "", 30)
					end
				end

                --
			end

			menu2.close()
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('press_menu')
		CurrentActionData = {zone = zone}
	end)
end

```

> Server

```

RegisterServerEvent('esx_shops:buyItem')
AddEventHandler('esx_shops:buyItem', function(itemName, amount, zone, cardnumber, xPlayer)
	-- is the player trying to exploit?
	if amount < 0 then
		return
	end

	-- get price
	local price = 0
	local itemLabel = ''
	for i=1, #ShopItems[zone], 1 do
		if ShopItems[zone][i].item == itemName then
			price = ShopItems[zone][i].price
			itemLabel = ShopItems[zone][i].label
			break
		end
	end
	price = price * amount

	TriggerEvent('gb_banking:removeShopMoney', price, cardnumber, itemName, amount, xPlayer)
end)

RegisterServerEvent('esx_shops:giveItem')
AddEventHandler('esx_shops:giveItem', function(itemName, amount, xPlayer)
	xPlayer.addInventoryItem(itemName, amount)
end)

RegisterServerEvent('atm:login')
AddEventHandler('atm:login', function(karta, podanyPIN, item, value, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('gb_banking:getPIN', karta, podanyPIN, item, value, zone, xPlayer)
end)

```

### ESX Paycheck function

```

ESX.StartPayCheck = function()

	function payCheck()
		local xPlayers = ESX.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			local job     = xPlayer.job.grade_name
			local salary  = xPlayer.job.grade_salary
				if salary > 0 then
					if job == 'unemployed' then -- unemployed
						TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
						TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_FLEECA', 9)
					elseif Config.EnableSocietyPayouts then -- possibly a society
						TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
							if society ~= nil then -- verified society
								TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
									if account.money >= salary then -- does the society money to pay its employees?
										TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
										account.removeMoney(salary)
		
										TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
									else
										TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_FLEECA', 1)
									end
								end)
							else -- not a society
								TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
								TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
							end
						end)
					else -- generic job
						TriggerEvent('gb_banking:addExtendedMoney', salary, xPlayer.identifier)
						TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9)
					end
				end

		end

		SetTimeout(Config.PaycheckInterval, payCheck)

	end

	SetTimeout(Config.PaycheckInterval, payCheck)

end

function checkingin(identifier) 
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.login FROM gb_banking WHERE gb_banking.realOwner = @realOwner", {
        ['@realOwner'] = identifier
    })
    if result[1] ~= nil then
        return result[1].realOwner
    end
    return nil
end

```

### Credits

- Made by [Nyxon](https://github.com/Nyxonn)
