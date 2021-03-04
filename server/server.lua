--[[ MADE BY Nyxon#4418 ]]--

print('[^3gb_banking^7] ^2Successfully initialized.^7')

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('gb_banking:updateIdentifier')
AddEventHandler('gb_banking:updateIdentifier', function(login, identifier)
	MySQL.Async.fetchAll('SELECT * FROM gb_banking WHERE identifier = @identifier', {['@identifier'] = identifier}, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute("UPDATE gb_banking SET identifier = @identifier2 WHERE identifier = @identifier", {
				['@identifier'] = identifier,
				['@identifier2'] = nil
			})
			MySQL.Async.execute("UPDATE gb_banking SET identifier = @identifier WHERE login = @login", {
				['@login'] = login,
				['@identifier'] = identifier
			})
		end
	end)
	MySQL.Async.execute("UPDATE gb_banking SET identifier = @identifier WHERE login = @login", {
		['@login'] = login,
		['@identifier'] = identifier
	})
end)

RegisterServerEvent('gb_banking:updateLoggedTrue')
AddEventHandler('gb_banking:updateLoggedTrue', function(login)
	MySQL.Async.execute("UPDATE gb_banking SET isLogged = @isLogged WHERE login = @login", {
		['@login'] = login,
		['@isLogged'] = 1
	})
end)

RegisterServerEvent('gb_banking:updateLoggedFalse')
AddEventHandler('gb_banking:updateLoggedFalse', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.execute("UPDATE gb_banking SET isLogged = @isLogged WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@isLogged'] = 0
	})
	TriggerClientEvent('focusoff', _source)
end)

AddEventHandler('playerDropped', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.execute("UPDATE gb_banking SET isLogged = @isLogged WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@isLogged'] = 0
	})
end)  

function checking(login)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.isLogged FROM gb_banking WHERE gb_banking.login = @login", {
        ['@login'] = login
    })
    if result[1] ~= nil then
        return result[1].isLogged
    end
    return nil
end

--[[ LOGOWANIE ]]--

RegisterServerEvent('bank:login')
AddEventHandler('bank:login', function(login, password)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local passwordS = loginInto(login)
	local imie = getOwnersName(login)
	local karta = getOwnersDebit(login)
	local pindo = getOwnersDcPIN(login)
	local numerek = getOwnersAccNum(login)

	local checkIfLogged = checking(login)

	if passwordS == password then
		if checkIfLogged == 0 then
			TriggerEvent('gb_banking:updateIdentifier', login, xPlayer.identifier)
			Wait(200)
			TriggerClientEvent('successlogin', _source, login, imie, karta, pindo, numerek)
			TriggerEvent('gb_banking:updateLoggedTrue', login)
			TriggerClientEvent('bank:result', _source, "success", Config.Logged)
		else
			TriggerClientEvent('bank:result', _source, "error", Config.CurrentlyLogged)
		end
	else
		TriggerClientEvent('bank:result', _source, "error", Config.WrongPassword)
	end

end)

function loginInto(login)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.password FROM gb_banking WHERE gb_banking.login = @login", {
        ['@login'] = login
    })
    if result[1] ~= nil then
        return result[1].password
    end
    return nil
end

function getOwnersName(login)
	local result = MySQL.Sync.fetchAll("SELECT name FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].name
    end
    return nil
end

function getOwnersDebit(login)
	local result = MySQL.Sync.fetchAll("SELECT debitcard FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].debitcard
    end
    return nil
end

function getOwnersAccNum(login)
	local result = MySQL.Sync.fetchAll("SELECT accountNumber FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].accountNumber
    end
    return nil
end

function getOwnersDcPIN(login)
	local result = MySQL.Sync.fetchAll("SELECT dc_pin FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].dc_pin
    end
    return nil
end

--[[ SKLEPY I BANKOMATY ]]--

RegisterServerEvent('gb_banking:getDcPIN')
AddEventHandler('gb_banking:getDcPIN', function(debitnummmm, podanypin, item, value, zone, xPlayer)
	local result = MySQL.Sync.fetchAll("SELECT gb_banking.dc_pin FROM gb_banking WHERE gb_banking.debitcard = @debitcard",{
		["@debitcard"] = debitnummmm
	})
	if result[1] ~= nil then
		if podanypin == result[1].dc_pin then
			TriggerEvent('esx_shops:buyItem', item, value, zone, debitnummmm, xPlayer)
		end
    end
    return nil
end)

--[[ IMIE I NAZWISKO ]]--

function GetCharacterName(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
	{
		['@identifier'] = xPlayer.identifier
	})
	if result[1] ~= nil and result[1].firstname ~= nil and result[1].lastname ~= nil then
		return result[1].firstname .. ' ' .. result[1].lastname
	else
		return GetPlayerName(_source)
	end
end

RegisterServerEvent('getmycasualname')
AddEventHandler('getmycasualname', function()
	local _source = source
	local name = GetCharacterName(_source)
	TriggerClientEvent('myname', _source, name)
end)

--[[ BLOKADA ID ORAZ LOGINU ]]--

function isLoginInUse(login)
	local result = MySQL.Sync.fetchAll('SELECT * FROM gb_banking WHERE login = @login',
	{
		['@login'] = login
	})
    if result[1] ~= nil then
        return true
    end
    return false
end

RegisterServerEvent('gb_banking:createnewdcpin')
AddEventHandler('gb_banking:createnewdcpin', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local dc_pin = math.random(1000, 9999)
	MySQL.Async.execute("UPDATE gb_banking SET dc_pin = @dc_pin WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@dc_pin'] = dc_pin
	})
	Wait(200)
	TriggerClientEvent('bank:result', _source, "success", Config.PINchanged)
end)

RegisterServerEvent('gb_banking:createnewcard')
AddEventHandler('gb_banking:createnewcard', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local debitcard = '54' .. math.random(10, 99) .. ' ' .. math.random(1000, 9999) .. ' ' .. math.random(1000, 9999)
	local base = 0
	base = getAccountBalance(xPlayer.identifier)

	if base < 1000 then
		TriggerClientEvent('bank:result', _source, "error", Config.NotEnoughMoney)
	else
		removeAccountBalance(xPlayer.identifier, 1000)
		MySQL.Async.execute("UPDATE gb_banking SET debitcard = @debitcard WHERE identifier = @identifier", {
			['@identifier'] = xPlayer.identifier,
			['@debitcard'] = debitcard
		})
		Wait(200)
		TriggerClientEvent('bank:result', _source, "success", Config.NewDebitCard)
	end
end)

RegisterServerEvent('gb_banking:deleteaccount')
AddEventHandler('gb_banking:deleteaccount', function(kodusuniecia, kodzapasowy)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local kod = 0
	kod = getBackup(xPlayer.identifier)
	if kodzapasowy == kod then
		MySQL.Async.execute("UPDATE gb_banking SET password = @password WHERE identifier = @identifier", {
			['@identifier'] = xPlayer.identifier,
			['@password'] = kodusuniecia
		})
		Wait(200)
		TriggerClientEvent('bank:result', _source, "success", Config.PasswordChanged)
		TriggerClientEvent('accountdeleted', _source)
	else
		TriggerClientEvent('bank:result', _source, "error", Config.WrongBackup)
		TriggerClientEvent('deletefail', _source)
	end
end)

function getBackup(identifier)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.removecode FROM gb_banking WHERE gb_banking.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result[1] ~= nil then
        return result[1].removecode
    end
    return nil
end

--[[ TWORZENIE KONTA ]]--

RegisterServerEvent('gb_banking:createnewaccount')
AddEventHandler('gb_banking:createnewaccount', function(login, password, removecode)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local name = GetCharacterName(_source)
	local dc_pin = math.random(1000, 9999)
	local debitcard = '54' .. math.random(10, 99) .. ' ' .. math.random(1000, 9999) .. ' ' .. math.random(1000, 9999)

	local accountnumber = '69 '.. math.random(1000, 9999) .. ' ' .. math.random(1000, 9999) .. ' ' .. math.random(1000, 9999)

	if login ~= '' and password ~= '' and removecode ~= '' then
		local checkingLogin = isLoginInUse(login)
		if string.len(removecode) == 4 then
					if checkingLogin then
					 	TriggerClientEvent('bank:result', _source, "error", Config.LoginInUse)
					else
						MySQL.Async.execute('INSERT INTO gb_banking (name, login, password, removecode, debitcard, dc_pin, isLogged, realOwner, mainAccount, accountNumber) VALUES (@name, @login, @password, @removecode, @debitcard, @dc_pin, @isLogged, @realOwner, @mainAccount, @accountNumber)',
						{
							['@name']   = name,
							['@login']	= login,
							['@password']	= password,
							['@removecode']	= removecode,
							['@debitcard'] = debitcard,
							['@dc_pin']	= dc_pin,
							['@isLogged'] = 0,
							['@realOwner'] = xPlayer.identifier,
							['@mainAccount'] = 0,
							['@accountNumber'] = accountnumber
						})
						TriggerClientEvent('bank:result', _source, "success", Config.AccountCreated)
					end
		else
			TriggerClientEvent('bank:result', _source, "error", Config.BackupCodeLenght)
		end
	else
		TriggerClientEvent('bank:result', _source, "error", Config.NullValues)
	end
end)

--[[ AKTUALIZACJA KONTA ]]--

RegisterServerEvent('bank:balance')
AddEventHandler('bank:balance', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalance(xPlayer.identifier)
	TriggerClientEvent('currentbalance1', _source, balance)
end)

--[[ FUNKCJE OBROTU ]]--


function getAccountBalance(identifier)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result[1] ~= nil then
        return result[1].balance
    end
    return nil
end

function getAccountBalanceEx(identifier)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.realOwner = @realOwner AND gb_banking.mainAccount = @mainAccount", {
		['@realOwner'] = identifier,
		['@mainAccount'] = 1
    })
    if result[1] ~= nil then
        return result[1].balance
    end
    return nil
end

--[[ MAIN ]]--

RegisterServerEvent('gb_banking:changeMainAccount')
AddEventHandler('gb_banking:changeMainAccount', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute("UPDATE gb_banking SET mainAccount = @mainAccount WHERE realOwner = @identifier AND mainAccount = @main2", {
		['@identifier'] = xPlayer.identifier,
		['@mainAccount'] = 0,
		['@main2'] = 1
	})

	MySQL.Async.execute("UPDATE gb_banking SET mainAccount = @mainAccount WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@mainAccount'] = 1
	})
	TriggerClientEvent('bank:result', _source, "error", Config.ChangedMainAccount)
end)

--[[ ESX ]]--

RegisterServerEvent('gb_banking:addExtendedMoney')
AddEventHandler('gb_banking:addExtendedMoney', function(salary, identifier)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalanceEx(identifier)

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE realOwner = @realOwner AND mainAccount = @mainAccount", {
		['@realOwner'] = identifier,
		['@mainAccount'] = 1,
		['@balance'] = balance + salary
	})
end)

--[[ SALDO ]]--

function addAccountBalance(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalance(xPlayer.identifier)

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@balance'] = balance + money
	})
end

function removeAccountBalance(identifier, money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalance(identifier)

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE identifier = @identifier", {
		['@identifier'] = identifier,
		['@balance'] = balance - money
	})
end


function getAccountBalanceShop(cardnumber)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.debitcard = @debitcard", {
        ['@debitcard'] = cardnumber
    })
    if result[1] ~= nil then
        return result[1].balance
    end
    return nil
end

RegisterServerEvent('gb_banking:removeShopMoney')
AddEventHandler('gb_banking:removeShopMoney', function(price, cardnumber, itemName, amount, xPlayer)
	local _source = source
	local balance = getAccountBalanceShop(cardnumber)

	if balance >= price then

		MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE debitcard = @debitcard", {
			['@debitcard'] = cardnumber,
			['@balance'] = balance - price
		})

		TriggerEvent('esx_shops:giveItem', itemName, amount, xPlayer)
	else
		TriggerClientEvent('esx:showNotification', _source, Config.NotEnoughMoney)
	end
end)

--[[ WPŁATA / WYPŁATA ]]--

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('bank:result', _source, "error", Config.WrongAmount)
	else
		xPlayer.removeMoney(amount)
		addAccountBalance(amount)
	--	Wait(500)
		TriggerClientEvent('bank:result', _source, "success", Config.MoneyDeposit)
		TriggerClientEvent('depositDONE', _source)
	end
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local base = 0

	base = getAccountBalance(xPlayer.identifier)

	if amount == nil or amount <= 0 or amount > base then
		TriggerClientEvent('bank:result', _source, "error", Config.WrongAmount)
	else
		removeAccountBalance(xPlayer.identifier, amount)
		xPlayer.addMoney(amount)
	--	Wait(500)
		TriggerClientEvent('bank:result', _source, "success", Config.MoneyWithdraw)
		TriggerClientEvent('withdrawDONE', _source)
	end
end)

--[[ PRZELEW ]]--

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(to, amountt)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local mybalance = 0
	local hisbalance = 0
	local amount = tonumber(amountt)
	local kontozioma = ifAccounttExists(to)
	local mojekonto = isAccMine(xPlayer.identifier)
	
	if kontozioma then
		mybalance = getAccountBalance(xPlayer.identifier)
		hisbalance = getAccountBalanceFromNumber(to)
	--	Wait(300)
		if to == mojekonto then
			TriggerClientEvent('bank:result', _source, "error", Config.TransferToMe)
		else
			if mybalance <= 0 or mybalance < amount or amount <= 0 then
				TriggerClientEvent('bank:result', _source, "error", Config.NotEnoughMoney)
			else
				removeAccountBalance(xPlayer.identifier, amount)
				addAccountBalanceSomeone(to, amount, hisbalance)
			--	Wait(300)
				TriggerClientEvent('bank:result', _source, "success", Config.TransferDone)
				TriggerClientEvent('transferDONE', _source)
			end
		end
	else
		TriggerClientEvent('bank:result', _source, "error", Config.WrongAccountNumber)
	end
end)

function isAccMine(identifier)
	local result = MySQL.Sync.fetchAll("SELECT accountNumber FROM gb_banking WHERE identifier = @identifier",{
		["@identifier"] = identifier
	})
    if result[1] ~= nil then
        return result[1].accountNumber
    end
    return nil
end

function ifAccounttExists(accountNumber)
	local result = MySQL.Sync.fetchAll("SELECT * FROM gb_banking WHERE accountNumber = @accountNumber",
	{
		["@accountNumber"] = tostring(accountNumber)
	})
    if result[1] ~= nil then
        return true
    end
    return false
end

function getAccountBalanceFromNumber(accNummmmmerm)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.accountNumber = @accountNumber", {
        ['@accountNumber'] = accNummmmmerm
    })
    if result[1] ~= nil then
        return result[1].balance
    end
    return nil
end

function addAccountBalanceSomeone(accNummmmmerm, money, zbalance)
	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE accountNumber = @accountNumber", {
		['@accountNumber'] = accNummmmmerm,
		['@balance'] = zbalance + money
	})
end

--[[ MADE BY Nyxon#4418 ]]--