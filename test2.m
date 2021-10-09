clear;
import Packet;
import Node;

xmin= 0;
xmax= 1000;
n = 60;
x_s = round(xmin+rand(1,n)*(xmax-xmin));
x_s = sort(x_s);
y_s = [5;10;15];
vehicles(50,1) = Node();
speeds = [10;20;30];
W = 4;
for i = 1:n
    vehicles(i).id = i;
    vehicles(i).x = x_s(i);
    vehicles(i).y = y_s(randi([1 3]));
    vehicles(i).packetToSend = Packet(vehicles(i));
    vehicles(i).range = 300;
    vehicles(i).acquiredSlot = randi([1 60]);
    vehicles(i).frameInfo(i) = 1;
    vehicles(i).speed = speeds(randi([1 3]));
    vehicles(i).backoff = randi([1 W]);
end


current_slot = 1;
round = 1;
numberOfTransmissions = zeros(n,1);
collisions = 0;
while round<6
    plot([vehicles.x],[vehicles.y],"r>");
    pause(0.01);
    for i = 1:n
        vehicles = vehicles(i).acquireHybridSlot(vehicles);
    end
    %checking for collisions
    allCollidingVehicles = [];
    for i = 1:n
        if vehicles(i).acquiredSlot == current_slot
            allCollidingVehicles = [allCollidingVehicles; i];
        end
    end
    
    %vehicles which are in the same THS
    for i = 1:numel(allCollidingVehicles)
        for j = 1:numel(allCollidingVehicles)
            if i == j
                continue;
            end
           node1 = vehicles(allCollidingVehicles(i));
           node2 = vehicles(allCollidingVehicles(j));
           if ismember(node1.id, node2.frameInfo) || ismember(node2.id, node1.frameInfo)
                w1 = node1.backoff; w2 = node2.backoff;
                if w1 > w2
                    vehicles(node1.id).acquiredSlot = 0;
                elseif w1 < w2
                    vehicles(node2.id).acquiredSlot = 0;
                else
                    vehicles(node1.id).acquiredSlot = 0;
                    vehicles(node2.id).acquiredSlot = 0;
                end
           end
        end
    end
    %end
    for i = 1:n
        [vehicles,numberOfTransmissions] = vehicles(i).sendPackets(vehicles,current_slot,numberOfTransmissions);
    end
    [vehicles,lostSlot] = arrayfun( @(x) x.processPacket(current_slot), vehicles);
    for s = 1:numel(lostSlot)
        if lostSlot(s) == 1
            collisions = collisions + 1;
        end
    end
    vehicles = arrayfun( @(x) x.incrementx(), vehicles);
    if current_slot == 60
        current_slot = 1;
        disp("round "+round+" over");
        round = round + 1;
    else
        current_slot = current_slot + 1;
    end
end

disp(collisions);