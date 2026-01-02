var open = false;
var currentLobby = null;
window.lastWeaponData = [];

window.addEventListener('message', function(event) {
    if (event.data.type === 'openmenu') {
        open = true;
        $(".root").css("display", "block");
        window.lastWeaponData = event.data.weapons;
        updateLobbyList(event.data.lobbies);
    } else if (event.data.type === 'showDashboard') {
        currentLobby = event.data.lobby;
        showDashboard(currentLobby);
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        if (open) Close();
    }
});

function Close() {
    if (open) {
        open = false;
        $(".root").css("display", "none");
        fetch('https://ns-lobbysystem/close', {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
}

$(document).ready(function() {
    $("#create-lobby-btn").click(function() {
        const lobbyName = $("#lobby-name-input").val();
        const lobbyType = $("#lobby-type-select").val();
        if (lobbyName) {
            fetch('https://ns-lobbysystem/createLobby', {
                method: 'POST',
                body: JSON.stringify({ name: lobbyName, type: lobbyType })
            });
        }
    });

    $(document).on('click', '.join-lobby-btn', function() {
        const lobbyId = $(this).data('lobby-id');
        fetch('https://ns-lobbysystem/joinLobby', {
            method: 'POST',
            body: JSON.stringify({ id: lobbyId })
        });
    });

    $("#back-to-lobbies-btn").click(function() {
        $("#lobby-dashboard").hide();
        $("#lobby-selection").show();
        // Optionally, tell the server the player left the lobby view
    });

    $("#start-game-btn").click(function() {
        const gameOptions = {};
        if (currentLobby.type === 'ramp') {
            gameOptions.gameType = 'ramp';
        } else if (currentLobby.type === 'pvp') {
            gameOptions.gameType = 'pvp';
            gameOptions.map = $("#pvp-map-select").val();
            gameOptions.weapon = $("#weapon-select").val();
            gameOptions.team = $("input[name='team']:checked").val();
        }

        fetch('https://ns-lobbysystem/startGame', {
            method: 'POST',
            body: JSON.stringify(gameOptions)
        });
    });
});

function updateLobbyList(lobbies) {
    const lobbyContainer = $('#lobby-list');
    lobbyContainer.empty();
    if (lobbies && lobbies.length > 0) {
        lobbies.forEach(lobby => {
            const lobbyElement = `
                <div class="lobby" style="border-color: #00FF85;">
                    <div class="lobby-things">
                        <div class="lobby-players">
                            <div class="circlething" style="box-shadow: #00FF85 0px 0px 20px 0px;"><div class="circlething-inner"></div></div>
                            ${lobby.players} Players
                        </div>
                        <div class="lobby-name" style="color: #00FF85;">${lobby.name} (${lobby.type})</div>
                        <div class="lobby-description">${lobby.status}</div>
                        <div class="lobby-button join-lobby-btn" style="color: #1a1a1a; background-color: #00FF85;" data-lobby-id="${lobby.id}">
                            Connect
                        </div>
                    </div>
                </div>`;
            lobbyContainer.append(lobbyElement);
        });
    } else {
        lobbyContainer.append('<p style="text-align: center; width: 100%;">No active lobbies. Create one!</p>');
    }
}

function showDashboard(lobby) {
    $("#lobby-selection").hide();
    $("#lobby-dashboard").show();
    $("#dashboard-lobby-name").text(lobby.name);
    updatePlayerList(lobby.players);

    const gameOptions = $("#game-options");
    gameOptions.empty();

    if (lobby.type === 'ramp') {
        // "Start Game" button is already there, no specific options needed
    } else if (lobby.type === 'pvp') {
        const weaponOptions = window.lastWeaponData.map(weapon => `<option value="${weapon}">${weapon.replace('WEAPON_', '')}</option>`).join('');
        gameOptions.append(`
            <select id="pvp-map-select">
                <option value="zakim">PVP Zakim</option>
                <option value="zaira">PVP Zaira</option>
            </select>
            <select id="weapon-select">
                ${weaponOptions}
            </select>
            <div>
                <label><input type="radio" name="team" value="TEAM1"> Team 1</label>
                <label><input type="radio" name="team" value="TEAM2"> Team 2</label>
            </div>
        `);
    }
}

function updatePlayerList(players) {
    const playerList = $("#player-list");
    playerList.empty();
    if (players && players.length > 0) {
        players.forEach(player => {
            playerList.append(`<li>${player.name}</li>`);
        });
    }
}
