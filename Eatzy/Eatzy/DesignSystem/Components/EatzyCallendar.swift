//
//  EatzyCallendar.swift
//  Eatzy
//

import SwiftUI

struct EatzyCallendar: View {
    @Binding private var selection: Date

    private let calendar: Calendar
    private let dates: [Date]

    init(
        selection: Binding<Date>,
        referenceDate: Date = .now,
        pastDayCount: Int = 10,
        futureDayCount: Int = 30
    ) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")

        let referenceDay = calendar.startOfDay(for: referenceDate)
        let dayRange = (-pastDayCount)...futureDayCount

        self._selection = selection
        self.calendar = calendar
        self.dates = dayRange.compactMap {
            calendar.date(byAdding: .day, value: $0, to: referenceDay)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(dates, id: \.self) { date in
                        dateButton(for: date)
                            .id(date)
                    }
                }
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .background(.coreWhite)
            .onAppear {
                proxy.scrollTo(normalizedSelection, anchor: .center)
            }
            .onChange(of: selection) { _, newSelection in
                withAnimation(.easeInOut(duration: 0.2)) {
                    // ScrollView가 허용하는 최소·최대 offset 안에서만 중앙 정렬됩니다.
                    proxy.scrollTo(calendar.startOfDay(for: newSelection), anchor: .center)
                }
            }
        }
    }

    private var normalizedSelection: Date {
        calendar.startOfDay(for: selection)
    }

    private func dateButton(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selection)
        let foregroundColor = isSelected ? Color.orange500 : Color.gray900

        return Button {
            selection = date
        } label: {
            VStack(alignment: .center, spacing: 8) {
                Text(date, format: .dateTime.day())
                    .applyEatzyFont(.button_14_m)
                    .foregroundStyle(foregroundColor)

                Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US_POSIX"))))
                    .applyEatzyFont(.caption_12_m)
                    .foregroundStyle(foregroundColor)

                Circle()
                    .fill(isSelected ? Color.orange500 : Color.clear)
                    .frame(width: 8, height: 8)
            }
            .padding(0)
            .frame(width: 50, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

