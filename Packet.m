classdef Packet
    properties
        id;
        FI;
    end
    
    methods
        function self = Packet(node)
            self.id = node.id;
            self.FI = node.frameInfo;
        end
    end
end