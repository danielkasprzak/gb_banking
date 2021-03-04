--[[ MADE BY Nyxon#4418 ]]--


--[[ READ README INSTRUCTIONS CAREFULLY ]]--

RegisterServerEvent('esx_shops:buyItem')
AddEventHandler('esx_shops:buyItem', function(itemName, amount, zone, cardnumber, xPlayer)
	if amount < 0 then
		return
	end

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

-- Check debit card and dc pin code
RegisterServerEvent('gb_bankingSHOP:login')
AddEventHandler('gb_bankingSHOP:login', function(karta, podanyPIN, item, value, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('gb_banking:getDcPIN', karta, podanyPIN, item, value, zone, xPlayer)
end)

-- Give bought item to player
RegisterServerEvent('esx_shops:giveItem')
AddEventHandler('esx_shops:giveItem', function(itemName, amount, xPlayer)
	xPlayer.addInventoryItem(itemName, amount)
end)

--[[ MADE BY Nyxon#4418 ]]--