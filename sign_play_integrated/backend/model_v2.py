import torch
import torch.nn as nn

class KeypointGRUModelV2(nn.Module):
    def __init__(self, input_dim=152, attn_dim=146, hidden_dim=256, num_classes=6):
        """
        input_dim: 전체 feature 차원 (152)
        attn_dim: attention에 사용할 feature 차원 (손 좌표+손가락 각도 146)
        hidden_dim: GRU hidden size
        num_classes: 클래스 개수
        """
        super().__init__()
        self.gru = nn.GRU(input_dim, hidden_dim, batch_first=True)

        # Attention Layer
        self.attn_proj = nn.Sequential(
            nn.Linear(attn_dim, 128),
            nn.Tanh(),
            nn.Linear(128, 1)
        )

        # 최종 Classifier
        self.classifier = nn.Sequential(
            nn.Linear(hidden_dim, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, num_classes)
        )

    def forward(self, x):  # x: (B, T, 152)
        rnn_out, _ = self.gru(x)  # (B, T, H)

        # Attention은 손 좌표(126) + 손가락 각도(20) = 146 차원 사용
        hand_feat = x[:, :, :146]  # (B, T, 146)
        attn_weights = torch.softmax(self.attn_proj(hand_feat), dim=1)  # (B, T, 1)

        # GRU 출력에 attention 적용
        feat = (rnn_out * attn_weights).sum(dim=1)  # (B, H)

        # 최종 클래스 예측
        return self.classifier(feat)  # (B, num_classes)
