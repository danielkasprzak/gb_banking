--[[ MADE BY goldblack#4418 ]]--


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
AddEventHandler('gb_banking:updateLoggedFalse', function(identifier)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.execute("UPDATE gb_banking SET isLogged = @isLogged WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@isLogged'] = 0
	})
	TriggerClientEvent('focusoff', _source)
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
	local karta = getOwnersCredit(login)
	local pindo = getOwnersPIN(login)

	-- local checkIfLogged = checking(login)

	if passwordS == password then
		-- if checkIfLogged == 0 then
		Wait(600)
			TriggerClientEvent('bank:result', _source, "success", Config.Logged)
			TriggerEvent('gb_banking:updateIdentifier', login, xPlayer.identifier)
			TriggerClientEvent('successlogin', _source, login, imie, karta, pindo)
			TriggerEvent('gb_banking:updateLoggedTrue', login)
		-- else
			-- TriggerClientEvent('bank:result', _source, "error", Config.CurrentlyLogged)
		-- end
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

function getOwnersCredit(login)
	local result = MySQL.Sync.fetchAll("SELECT creditcard FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].creditcard
    end
    return nil
end

function getOwnersPIN(login)
	local result = MySQL.Sync.fetchAll("SELECT pin FROM gb_banking WHERE login = @login",{
		["@login"] = login
	})
    if result[1] ~= nil then
        return result[1].pin
    end
    return nil
end

--[[ SKLEPY I BANKOMATY ]]--

RegisterServerEvent('gb_banking:getPIN')
AddEventHandler('gb_banking:getPIN', function(creditnumber, podanypin, item, value, zone, xPlayer)
	local result = MySQL.Sync.fetchAll("SELECT gb_banking.pin FROM gb_banking WHERE gb_banking.creditcard = @creditcard",{
		["@creditcard"] = creditnumber
	})
	if result[1] ~= nil then
		if podanypin == result[1].pin then
			TriggerEvent('esx_shops:buyItem', item, value, zone, creditnumber, xPlayer)
		end
    end
    return nil
end)

--[[ IMIE I NAZWISKO ]]--

function GetCharacterName(source)
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
	{
		['@identifier'] = GetPlayerIdentifiers(source)[1]
	})

	if result[1] ~= nil and result[1].firstname ~= nil and result[1].lastname ~= nil then
		return result[1].firstname .. ' ' .. result[1].lastname
	else
		return GetPlayerName(source)
	end
end

RegisterServerEvent('getmycasualname')
AddEventHandler('getmycasualname', function()
	local _source = source
	local name = ''
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
	{
		['@identifier'] = GetPlayerIdentifiers(source)[1]
	})
	if result[1] ~= nil and result[1].firstname ~= nil and result[1].lastname ~= nil then
		name = result[1].firstname .. ' ' .. result[1].lastname
	else
		name = GetPlayerName(source)
	end
	TriggerClientEvent('myname', _source, name)
end)

--[[ BLOKADA ID ORAZ LOGINU ]]--

-- function getLoginInfo(identifier)
--     local result = MySQL.Sync.fetchAll("SELECT gb_banking.login FROM gb_banking WHERE gb_banking.realOwner = @realOwner", {
--         ['@realOwner'] = identifier
--     })
--     if result[1] ~= nil then
--         return result[1].login
--     end
--     return nil
-- end

-- function checkMyId(login) 
--     local result = MySQL.Sync.fetchAll("SELECT gb_banking.realOwner FROM gb_banking WHERE gb_banking.login = @login", {
--         ['@login'] = login
--     })
--     if result[1] ~= nil then
--         return result[1].realOwner
--     end
--     return nil
-- end

RegisterServerEvent('gb_banking:createnewpin')
AddEventHandler('gb_banking:createnewpin', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local pin = math.random(1000, 9999)
	MySQL.Async.execute("UPDATE gb_banking SET pin = @pin WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@pin'] = pin
	})
	Wait(200)
	TriggerClientEvent('bank:result', _source, "success", Config.PINchanged)
end)

RegisterServerEvent('gb_banking:createnewcard')
AddEventHandler('gb_banking:createnewcard', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local creditcard = '54' .. math.random(10000000, 99999999)
	local base = 0
	base = getAccountBalance(xPlayer.identifier)

	if base < 1000 then
		TriggerClientEvent('bank:result', _source, "error", Config.NotEnoughMoney)
	else
		removeAccountBalance(xPlayer.identifier, 1000)
		MySQL.Async.execute("UPDATE gb_banking SET creditcard = @creditcard WHERE identifier = @identifier", {
			['@identifier'] = xPlayer.identifier,
			['@creditcard'] = creditcard
		})
		Wait(200)
		TriggerClientEvent('bank:result', _source, "success", Config.NewCreditCard)
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
	-- local loginIn = getLoginInfo(xPlayer.identifier)
	-- local myid = checkMyId(login)
	local pin = math.random(1000, 9999)
	local creditcard = '54' .. math.random(10000000, 99999999)
	if login ~= '' and password ~= '' and removecode ~= '' then
		if string.len(removecode) <= 4 then
			-- MySQL.Async.fetchAll('SELECT * FROM gb_banking WHERE realOwner = @realOwner', {['@realOwner'] = xPlayer.identifier}, function(result)
					-- if loginIn ~= nil then
					-- 	TriggerClientEvent('bank:result', _source, "error", Config.ArleadyHaveAccount)
					-- elseif myid ~= nil then
					-- 	TriggerClientEvent('bank:result', _source, "error", Config.LoginInUse)
					-- else
						MySQL.Async.execute('INSERT INTO gb_banking (name, login, password, removecode, creditcard, pin, isLogged, realOwner, mainAccount) VALUES (@name, @login, @password, @removecode, @creditcard, @pin, @isLogged, @realOwner, @mainAccount)',
						{
							['@name']   = name,
							['@login']	= login,
							['@password']	= password,
							['@removecode']	= removecode,
							['@creditcard'] = creditcard,
							['@pin']	= pin,
							['@isLogged'] = 0,
							['@realOwner'] = xPlayer.identifier,
							['@mainAccount'] = 0 -- NEW
						})
						TriggerClientEvent('bank:result', _source, "success", Config.AccountCreated)
					-- end
			-- end)
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

	local newBalance = balance + salary

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE realOwner = @realOwner AND mainAccount = @mainAccount", {
		['@realOwner'] = identifier,
		['@mainAccount'] = 1,
		['@balance'] = newBalance
	})
end)

--[[ SALDO ]]--

function addAccountBalance(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalance(xPlayer.identifier)
	local newBalance = balance + money

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE identifier = @identifier", {
		['@identifier'] = xPlayer.identifier,
		['@balance'] = newBalance
	})
end

function removeAccountBalance(identifier, money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local balance = getAccountBalance(identifier)
	local newBalance = balance - money

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE identifier = @identifier", {
		['@identifier'] = identifier,
		['@balance'] = newBalance
	})
end


function getAccountBalanceShop(cardnumber)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.creditcard = @creditcard", {
        ['@creditcard'] = cardnumber
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

		local newBalance = balance - price

		MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE creditcard = @creditcard", {
			['@creditcard'] = cardnumber,
			['@balance'] = newBalance
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
		Wait(500)
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
		Wait(500)
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
	--local idgracza = ifCreditExists(to)
	local mojakarta = getOwnersCredit2(xPlayer.identifier)
	
	-- if idgracza == nil then
	-- 	TriggerClientEvent('bank:result', _source, "error", "Nieprawidłowy numer karty")
	-- else
		mybalance = getAccountBalance(xPlayer.identifier)
		hisbalance = getAccountBalanceFromCredit(to)
		Wait(300)
		if to == mojakarta then
			TriggerClientEvent('bank:result', _source, "error", Config.TransferToMe)
		else
			if mybalance <= 0 or mybalance < amount or amount <= 0 then
				TriggerClientEvent('bank:result', _source, "error", Config.NotEnoughMoney)
			else
				removeAccountBalance(xPlayer.identifier, amount)
				addAccountBalanceSomeone(to, amount, hisbalance)
				Wait(300)
				TriggerClientEvent('bank:result', _source, "success", Config.TransferDone)
				TriggerClientEvent('transferDONE', _source)
			end
		end
	-- end
end)

function getOwnersCredit2(identifier)
	local result = MySQL.Sync.fetchAll("SELECT creditcard FROM gb_banking WHERE identifier = @identifier",{
		["@identifier"] = identifier
	})
    if result[1] ~= nil then
        return result[1].creditcard
    end
    return nil
end

function ifCreditExists(creditnum)
	local result = MySQL.Sync.fetchAll("SELECT * FROM gb_banking WHERE creditcard = @creditcard",{
		["@creditcard"] = creditnum
	})
    if result[1] ~= nil then
        return result[1].creditcard
    end
    return nil
end

function getAccountBalanceFromCredit(creditenumber)
    local result = MySQL.Sync.fetchAll("SELECT gb_banking.balance FROM gb_banking WHERE gb_banking.creditcard = @creditcard", {
        ['@creditcard'] = creditenumber
    })
    if result[1] ~= nil then
        return result[1].balance
    end
    return nil
end

function addAccountBalanceSomeone(creditcard, money, zbalance)
	local _source = source
	local newBalance = zbalance + money

	MySQL.Async.execute("UPDATE gb_banking SET balance = @balance WHERE creditcard = @creditcard", {
		['@creditcard'] = creditcard,
		['@balance'] = newBalance
	})
end

--[[ MADE BY goldblack#4418 ]]--